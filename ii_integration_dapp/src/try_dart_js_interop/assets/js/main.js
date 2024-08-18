import { createActor } from "../../../declarations/greet_backend";
import { AuthClient } from "@dfinity/auth-client";
import { HttpAgent } from "@dfinity/agent";
import {fromHexString} from "@dfinity/identity/lib/cjs/buffer";
import { Ed25519PublicKey, ECDSAKeyIdentity, DelegationIdentity, DelegationChain } from "@dfinity/identity";

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


    const login = async (url_text) => {


        let appPublicKey;
        let delegationChain;

        var publicKeyIndex = url_text.indexOf("sessionkey=");
        if (publicKeyIndex !== -1) {
            // Parse the public key.
            var publicKeyString = url_text.substring(publicKeyIndex + "sessionkey=".length);
            var hex = fromHexString(publicKeyString)
            appPublicKey = Ed25519PublicKey.fromDer(hex);
        }


        var middleKeyIdentity = await ECDSAKeyIdentity.generate();

        const authClient = await AuthClient.create({identity: middleKeyIdentity});


        return new Promise((resolve, reject) => {
            authClient.login({
                identityProvider: "https://identity.ic0.app",
                onSuccess: async () => {
                    const middleIdentity = authClient.getIdentity();

                    const principal = middleIdentity.getPrincipal();
                    myConsoleLog("Inside js principal:", principal.toString());
                    window._principal = principal;
                    window._identity = middleIdentity;
                    myConsoleLog("Wow Inside js  Zalogowano", window.principal)



                    // Create another delegation with the app public key, then we have two delegations on the chain.
                    if (appPublicKey != null && middleIdentity instanceof DelegationIdentity) {
                        let middleToApp = await DelegationChain.create(
                            middleKeyIdentity,
                            appPublicKey,
                            new Date(Date.now() + 15 * 60 * 1000),
                            { previous: middleIdentity.getDelegation() },
                        );

                        delegationChain = middleToApp;
                    }
                    // Create another delegation with the app public key, then we have two delegations on the chain.

                    if (delegationChain == null){
                        console.log("Invalid delegation chain.");
                        return false;
                    }
                
                    var delegationString = JSON.stringify(delegationChain.toJSON());



                    const host = process.env.DFX_NETWORK === 'local' ? 'http://127.0.0.1:4943' : 'https://ic0.app';
                    const agent = new HttpAgent({ middleIdentity, host });
                    window.actor = createActor(process.env.CANISTER_ID_GREET_BACKEND, { agent });
                    const greeting = await window.actor.greet();
                    myConsoleLog("Inside js Greeting with Promise: ", greeting);

                    // var url = "internetidentity://authorize?";
                    // var delegationString = JSON.stringify(delegationChain.toJSON());
                    // url = url + "delegation=" + encodeURIComponent(delegationString);


                    resolve(delegationString);
                },
                onError: async (error) => {
                    console.error(`Inside js An error occurred: ${error}`);
                    reject(error);
                }
            });
        });
    }
    window._login = login;



}



window.onload = init;


function myConsoleLog(firstParam, secondParam) {
    console.log(`${firstParam} + ${JSON.stringify(secondParam)} , ${JSON.stringify(secondParam)}`);
}