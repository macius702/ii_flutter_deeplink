

const init = () => {
    const showAlert = (message) => {
        alert(message);
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
    
        // Create an auth client.
        var middleKeyIdentity = await ECDSAKeyIdentity.generate();
        let authClient = await AuthClient.create({
            identity: middleKeyIdentity,
        });
    
        // Start the login process and wait for it to finish.
        await new Promise((resolve) => {
            authClient.login({
                identityProvider: "https://identity.ic0.app/#authorize",
                onSuccess: resolve,
            });
        });
    
        // At this point we're authenticated, and we can get the identity from the auth client.
        const middleIdentity = authClient.getIdentity();
    
        // Using the identity obtained from the auth client to create an agent to interact with the IC.
        const agent = new HttpAgent({identity: middleIdentity});
        actor = createActor(process.env.GREET_BACKEND_CANISTER_ID, {
            agent,
        });
    
        // Create another delegation with the app public key, then we have two delegations on the chain.
        if (appPublicKey != null && middleIdentity instanceof DelegationIdentity ) {
            let middleToApp = await DelegationChain.create(
                middleKeyIdentity,
                appPublicKey,
                new Date(Date.now() + 15 * 60 * 1000),
                { previous: middleIdentity.getDelegation() },
            );
    
            delegationChain = middleToApp;
        }
    
        return false;
    }
    window._login = login;
    


}



window.onload = init;



