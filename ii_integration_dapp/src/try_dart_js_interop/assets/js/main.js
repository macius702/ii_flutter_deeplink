

const init = () => {
    const showAlert = (message) => {
        alert(message);
    }
    window._showAlert = showAlert;

    const requestFullScreen = () => {
        document.documentElement.requestFullscreen();
    }
    window._requestFullScreen = requestFullScreen;

}



window.onload = init;



