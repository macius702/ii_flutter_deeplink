import { createActor } from "../../../declarations/greet_backend";
import { AuthClient } from "@dfinity/auth-client";
import { HttpAgent } from "@dfinity/agent";

const init = () => {
    const showAlert = (message) => {

        alert(message);
        console.log('Before log process.env');

        if (process.env.GREET_BACKEND_CANISTER_ID) {
            console.log(process.env.GREET_BACKEND_CANISTER_ID);
        } else if (process.env.CANISTER_ID_GREET_BACKEND) {
            console.log(process.env.CANISTER_ID_GREET_BACKEND);
        } else {
            console.log('Both GREET_BACKEND_CANISTER_ID and CANISTER_ID_GREET_BACKEND are not set');
        }

        console.log('After log process.env');
    }
    window._showAlert = showAlert;

    const requestFullScreen = () => {
        document.documentElement.requestFullscreen();
    }
    window._requestFullScreen = requestFullScreen;

    const getSomeAsyncData = async () => {
        await new Promise((resolve, _) => setTimeout(resolve, 1000));
        return "foobar";
    }
    window._getSomeAsyncData = getSomeAsyncData;


    const login = async () => {
        const authClient = await AuthClient.create();
        await authClient.login({
            identityProvider: "https://identity.ic0.app",
            onSuccess: async () => {
                const identity = authClient.getIdentity();
                const principal = identity.getPrincipal();
                window._principal = principal;
                window._identity = identity;
                console.log("Zalogowano", window.principal)

                const host = process.env.DFX_NETWORK === 'local' ? 'http://127.0.0.1:4943' : 'https://ic0.app';
                const agent = new HttpAgent({ identity, host });
                window.actor = createActor(process.env.CANISTER_ID_GREET_BACKEND, { agent });
                const greeting = await window.actor.greet();
                myConsoleLog("Greeting: ", greeting);

            },
            onError: async (error) => {
                // mtlk todo - try/catch needed ?
                // Do something asynchronous here...
                console.error(`An error occurred: ${error}`);
            }
        });
    }
    window._login = login;



}



window.onload = init;


function myConsoleLog(firstParam, secondParam) {
    console.log(`${firstParam} + ${JSON.stringify(secondParam)} , ${JSON.stringify(secondParam)}`);
}