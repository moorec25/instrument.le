import * as LocalAuthentication from 'expo-local-authentication';
import * as SecureStore from "expo-secure-store";

export function onAuthenticate () {
    // Create authentication promise
    const auth = LocalAuthentication.authenticateAsync({
        promptMessage: 'Authenticate',
        fallbackLabel: 'Enter Password',
    });
    // Handle the authentication result
    return auth.then(_ => {
        // Get the user's ID from SecureStore
        const userId = SecureStore.getItem("userID");
        // Check if UUID already exists
        if (userId == undefined) {
            // Create a new UUID for this user (timestamp + random number)
            const uuid = Date.now().toString() + '_' + Math.floor(Math.random() * 10_000).toString().substring(0, 5);
            // Store the UUID in SecureStore
            SecureStore.setItem("userID", uuid);
            // Set to be only on this device only
            SecureStore.ALWAYS_THIS_DEVICE_ONLY = true;
            // Return the UUID
            return {
                success: true,
                userId: uuid,
            }
        }
        else {
            // Return the UUID
            return {
                success: true,
                userId: userId,
            }
        }
    }).catch(err => {
        // Debug print
        console.error(err);
        // Return failure
        return {
            success: false,
            userId: null,
        }
    });
}