import * as React from 'react';
import { StyleSheet, View, Text } from 'react-native';
import { init, getGroupMembers, login } from 'react-native-tx-im';
import { useEffect } from 'react';

export default function App() {
  useEffect(() => {
    console.log(555);
    init(1)
      .then((v) => {
        console.warn(v);
        login({
          userSig: '33',
          userId: '555',
          nickName: '333',
          avatar: 'avatar',
        })
          .then(() => {
            getGroupMembers('123').then((v) => console.log(v));
          })
          .catch((e) => {
            console.warn(e);
          });
      })
      .catch((e) => console.warn(e));
  }, []);

  return (
    <View style={styles.container}>
      <Text>Result</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
