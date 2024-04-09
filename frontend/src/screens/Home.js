import React, { useRef, useEffect, useState } from 'react';
import { BackHandler, Animated, View, Text, TouchableOpacity, StyleSheet, Dimensions, Alert } from 'react-native';
import * as SecureStore from "expo-secure-store";

// Map of buttons to the screen they navigate to
const screenMap = {
    'Play 🎶':     'Game',
    'Listen 🎧':   'ChooseSong',
    'Separate ⚙️': 'FindSeparate'
}

// Get the screen width
const screenWidth = Dimensions.get('window').width;

// Print screen width to console
console.log(`Screen is ${screenWidth}`);

const FadeInView = props => {

    // Use the useRef hook to create a fadeAnim variable
    const fadeAnim = useRef(new Animated.Value(0)).current;
  
    useEffect(() => {
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 3000,
        useNativeDriver: true,
      }).start();
    }, [fadeAnim]);
  
    return (
      <Animated.View
        style={{
          ...props.style,
          opacity: fadeAnim,
        }}>
        {props.children}
      </Animated.View>
    );
};
  

const Home = ({ navigation }) => {
    // Function to handle navigation to different screens
    const handleClick = (screen) => navigation.navigate(screen);
    // If the user clicks the logo 10 times, they become an admin
    const [numClick, setNumClick] = useState(0);

    // Handle back presses on the home screen by exiting the app
    useEffect(() => {
        // Add the event listener to exit the app on a hardware back press
        const backHandler = BackHandler.addEventListener("hardwareBackPress", BackHandler.exitApp);
        // Cleanup function to remove event listener after app exits
        return () => backHandler.remove();
    }, []);

    // Hacky function to let user change their ID :hehe:
    const adminHack = () => {
        setNumClick(numClick + 1);
        // If the user clicks the logo 10 times, their ID is set to "Admin"
        if (numClick >= 25) {
            // Alert the user that they are now an admin
            Alert.alert('Admin Hack', 'Your userId has been set to `Admin`');
            // Store the UUID in SecureStore
            SecureStore.setItem("userID", "Admin");
        }
    }

    return (
        <FadeInView style={styles.container}>
            <TouchableOpacity onPress={adminHack} activeOpacity={1}>
                <View style={[styles.logo, styles.shadowProp]}>
                    <Text style={styles.textlogo}>instrument.le</Text>
                </View>
            </TouchableOpacity>
            <View>
                {
                    Object.keys(screenMap).map((button, index) => (
                        // Create a button for each item in the screenMap, mapped to the navigation function
                        <TouchableOpacity style={ [styles.button, styles.shadowProp] } key={ index } onPress = {() => handleClick(screenMap[button])}>
                            <Text style={styles.textbutton}>{button}</Text>
                        </TouchableOpacity>
                    ))
                }
            </View>
        </FadeInView>
    );
}


const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        backgroundColor: '#FFF4E6',
        padding: 35,
    },
    button: {
        alignItems: 'center',
        backgroundColor: '#4B3832',
        padding: 20,
        borderColor: '#3C2F2F',
        borderWidth: 3,
        borderTopLeftRadius: 20,
        borderTopRightRadius: 20,
        borderBottomLeftRadius: 20,
        borderBottomRightRadius: 20,
        marginBottom: 29,
        marginHorizontal: 25,
    },
    textbutton: {
        color: '#FFF4E6',
        textAlign: 'center',
        fontSize: 32,
    },
    logo:{
        alignItems: 'center',
        backgroundColor: '#BE9B7B',
        padding: 20,
        borderColor: '#3C2F2F',
        borderWidth: 3,
        borderTopLeftRadius: 50,
        borderTopRightRadius: 50,
        borderBottomLeftRadius: 50,
        borderBottomRightRadius: 50,
        marginBottom: 80,
    },
    textlogo: {
        color: '#3C2F2F',
        textAlign: 'center',
        fontSize: screenWidth / 9,
        flexShrink: 0,
    },
    shadowProp: {
        shadowColor: '#171717',
        shadowOffset: {width: -2, height: 4},
        shadowOpacity: 0.3,
        shadowRadius: 4,
    }
})

export default Home;