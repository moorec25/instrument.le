import React from 'react';
import { View, Text, StyleSheet, ActivityIndicator } from 'react-native';

export const LoadingScreen = () => {
    return (
        <View style={styles.loadingContainer}>
            <ActivityIndicator size="large" color="#FFF4E6" />
            <Text style={styles.loadingText}>Loading...</Text>
        </View>
    );
}

const styles = StyleSheet.create({
    loadingContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#3C2F2F',
    },
    loadingText: {
        marginTop: 20,
        fontSize: 18,
        color: '#FFF4E6',
    },
    loadingGIF: {
        width: 100,
        height: 100,
    },
});