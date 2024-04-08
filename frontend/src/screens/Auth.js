import React, { useState, useEffect, setState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Stack } from 'react-native';
import * as LocalAuthentication from 'expo-local-authentication';
import * as SecureStore from "expo-secure-store";

const screenMap = {
  'Add New': 'FindSeparate',
  'Separate': 'PlaySeparate',
}

const Auth = ({navigation}) => {

  const handleClick = (screen) => navigation.navigate(screen);

  const[isBiometricSupported, setIsBiometricSupported] = useState(false);
  const[isAuthenticated, setIsAuthenticated] = useState(false);
  const[key, setKey] = useState();
  const[value, setValue] = useState();

  useEffect(() => {
    (async () => {
      const compatible = await LocalAuthentication.hasHardwareAsync();
      setIsBiometricSupported(compatible);
    })();
  });

  function onAuthenticate () {
    const auth = LocalAuthentication.authenticateAsync({
      promptMessage: 'Authenticate',
      fallbackLabel: 'Enter Password',
    });
    auth.then(result => {
      setIsAuthenticated(result.success);
      if (SecureStore.getItem("userID") == undefined){
        SecureStore.setItem("userID", (Date.now()*(Math.random())).toString());
        setValue(SecureStore.getItem("userID"));
        SecureStore.ALWAYS_THIS_DEVICE_ONLY = true;
      }
      else{
        setValue(SecureStore.getItem("userID"));
      }
        console.log(result.success);
        console.log(SecureStore.getItem("userID"));
        console.log(value);
    });
  }


  return(
    <View style={styles.container}>
      { isAuthenticated
        ? 
        <View>
          <View>
          {
            Object.keys(screenMap).map((button, index) => (
                // Create a button for each item in the screenMap, mapped to the navigation function
                <TouchableOpacity style={styles.button} key = {index} onPress = {() => handleClick(screenMap[button])}>
                    <Text style={styles.textfont}>{button}</Text>
                </TouchableOpacity>
            ))
          }
          </View>
        <TouchableOpacity onPress={() => setIsAuthenticated(false)} style={styles.button}>
          <Text style={styles.textfont}>Logout</Text>
        </TouchableOpacity>
        </View>
        : 
        <View>
          <TouchableOpacity style={styles.button} onPress = {onAuthenticate}>
            <Text style={styles.textfont}>Login</Text>
          </TouchableOpacity>
        </View>
      }
    </View>
  )
};


const styles = StyleSheet.create({
  container: {
      flex: 1,
      alignItems: 'center',
      justifyContent: 'center',
      backgroundColor: '#FFF4E6',
  },
  buttoncontainer: {
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'center',
  },
  textfont: {
      color: '#FFF4E6',
      textAlign: 'left',
      fontSize: 20,
  },
  button: {
      alignContent: 'flex-start',
      justifyContent: 'flex-start',
      backgroundColor: '#4B3832',
      minWidth: '85%',
      padding: 10,
      paddingHorizontal: 15,
      marginTop: 1,
  }
});

export default Auth;