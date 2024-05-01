function DynamicResolution() {
    var screenWidth = window.screen.width;
    var screenHeight = window.screen.height;
    var resolution = screenWidth + 'x' + screenHeight;
    var httpRequest = new XMLHttpRequest();
    var url = '/reso?x=' + resolution
    httpRequest.open('GET', url, false);
    httpRequest.setRequestHeader('Content-Type', 'plain/text');
    httpRequest.onreadystatechange = function() {
        if (httpRequest.readyState === XMLHttpRequest.DONE) {
            var serverResponse = httpRequest.responseText;
            setTimeout(function() {
                if (serverResponse === 'error') {
                    alert('Ha ocurrido un error');
                } else if (serverResponse === 'max_containers') { 
                    window.location.replace('https://_domain_/');
                } else {
                    window.location.href = '/' + serverResponse;
                }
            }, 5000);
        }
    };

    // Enviar la solicitud al servidor
    httpRequest.send(null);
}
