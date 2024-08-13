



import { createActor } from "../../../declarations/greet_backend";
import { ECDSAKeyIdentity } from "@dfinity/identity";
import { AuthClient } from "@dfinity/auth-client";
import { HttpAgent } from "@dfinity/agent";

import { Principal } from '@dfinity/principal';



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

    // const login = async () => {
    //     let appPublicKey;
    //     window.actor = greet_backend
    //     myConsoleLog("Entering login function");

    //     try {
    //         // Create an auth client.
    //         var middleKeyIdentity = await ECDSAKeyIdentity.generate();
    //         myConsoleLog("middleKeyIdentity generated: ", middleKeyIdentity);

    //         let authClient = await AuthClient.create({
    //             identity: middleKeyIdentity,
    //         });
    //         myConsoleLog("AuthClient created: ", authClient);

    //         // Start the login process and wait for it to finish.
    //         await new Promise((resolve) => {
    //             authClient.login({
    //                 identityProvider: "https://identity.ic0.app/#authorize",
    //                 onSuccess: resolve,
    //             });
    //         });
    //         myConsoleLog("Login process finished");

    //         // At thhis point we're authenticated, and we can get the identity from the auth client.
    //         const middleIdentity = authClient.getIdentity();
    //         myConsoleLog("middleIdentity obtained: ", middleIdentity);

    //         // Using the identity obtained from the auth client to create an agent to interact with the IC.
    //         const agent = new HttpAgent({ identity: middleIdentity });
    //         myConsoleLog("HttpAgent created: ", agent);
    //         const gbci = process.env.GREET_BACKEND_CANISTER_ID;
    //         window.actor = createActor(gbci, {
    //             agent,
    //         });


    //         if (window.actor === null) {
    //             myConsoleLog("window.actor is null");
    //         } else {
    //             myConsoleLog("window.actor is not null");
    //         }

    //         if (window.actor === undefined) {
    //             myConsoleLog("window.actor is undefined");
    //         } else {
    //             myConsoleLog("window.actor is not undefined");
    //         }

    //         myConsoleLog("Actor created: ", window.actor);
    //         // Log the type of window.actor
    //         myConsoleLog("Type of actor: ", typeof window.actor);

    //         // If window.actor is an object, log its properties
    //         if (typeof window.actor === 'object' && window.actor !== null) {
    //             myConsoleLog("Properties of actor: ", Object.keys(window.actor));
    //         }

    //         // If window.actor is a function, log its name and length (number of parameters)
    //         if (typeof window.actor === 'function') {
    //             myConsoleLog("Name of actor function: ", window.actor.name);
    //             myConsoleLog("Number of parameters of actor function: ", window.actor.length);
    //         }

    //         // Create another delegation with the app public key, then we have two delegations on the chain.
    //         if (appPublicKey != null && middleIdentity instanceof DelegationIdentity) {
    //             let middleToApp = await DelegationChain.create(
    //                 middleKeyIdentity,
    //                 appPublicKey,
    //                 new Date(Date.now() + 15 * 60 * 1000),
    //                 { previous: middleIdentity.getDelegation() },
    //             );
    //             myConsoleLog("middleToApp created: ", middleToApp);
    //             delegationChain = middleToApp;
    //         }

    //         const greeting = await actor.greet();
    //         myConsoleLog("Greeting: ", greeting);


    //     } catch (error) {
    //         myConsoleLog("Error: ", error);
    //         return false;

    //     }
    //     myConsoleLog("Returning false");
    //     return false;
    // }

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

                // await window._getUserData()
                //await window._getAllUsers()
            }
        })
    }
    window._login = login;

    const isUserLogged = () => {
        if (!window._identity || !window._principal || window._principal === Principal.anonymous()) {
            throw new Error("PLZ log in")
        }
        return {
            identity: window._identity,
            principal: window._principal
        }
    }
    window._isUserLogged = isUserLogged;


    const getUserData = async () => {
        const { principal } = window._isUserLogged()
        const maybeUserData = await greet_backend.get_user(principal)
        if (maybeUserData.length === 0) {
            window._userData = undefined
        } else {
            window._userData = maybeUserData[0]
        }
        console.log("User data", window._userData)
    }
    window._getUserData = getUserData;

}



window.onload = init;


function myConsoleLog(firstParam, secondParam) {
    console.log(`${firstParam} + ${JSON.stringify(secondParam)} , ${JSON.stringify(secondParam)}`);
}