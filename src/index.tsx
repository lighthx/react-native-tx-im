import { NativeModules } from 'react-native';

type TxImType = {
  multiply(a: number, b: number): Promise<number>;
};

const { TxIm } = NativeModules;

export default TxIm as TxImType;
