import React, { useEffect } from 'react';
import { BackHandler, View, Text, TouchableOpacity, Image, StyleSheet, Dimensions } from 'react-native';

// Map of buttons to the screen they navigate to
const screenMap = {
    'Play 🎶':     'Game',
    'Listen 🎧':   'ChooseSong',
    'Separate ⚙️': 'FindSeparate',
}

// Get the screen width
const screenWidth = Dimensions.get('window').width;

// Print screen width to console
console.log(`Screen is ${screenWidth}`);

const Home = ({ navigation }) => {

    // Function to handle navigation to different screens
    const handleClick = (screen) => navigation.navigate(screen);

    // Handle back presses on the home screen by exiting the app
    useEffect(() => {
        // Add the event listener to exit the app on a hardware back press
        const backHandler = BackHandler.addEventListener("hardwareBackPress", BackHandler.exitApp);
        // Cleanup function to remove event listener after app exits
        return () => backHandler.remove();
      }, []);

    return (
        <View style={styles.container}>
            <View style={ [styles.logo, styles.shadowProp] }>
                <Text style={ styles.textlogo } numberOfLines={ 1 }>
                    instrument.le
                </Text>
            </View>
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
        </View>
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