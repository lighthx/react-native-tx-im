import { NativeModules, NativeEventEmitter } from 'react-native';

const { TxIm } = NativeModules;
const txImEmitter = new NativeEventEmitter(TxIm);
export const init = async (sdkAppId: number) => {
  return await TxIm.init(sdkAppId);
};

export const login = async ({
  userSig,
  userId,
  nickName,
  avatar,
}: {
  userSig: string;
  userId: string;
  nickName: string;
  avatar: String;
}) => {
  return await TxIm.login(userSig, userId, nickName, avatar);
};

export const joinGroup = async (groupId: string) => {
  return await TxIm.joinGroup(groupId);
};

export const sendTextMessage = async ({
  message,
  userId,
}: {
  message: string;
  userId: string;
}) => {
  return await TxIm.sendTextMessage(message, userId);
};

export const sendTextGroupMessage = async ({
  message,
  groupId,
}: {
  message: string;
  groupId: string;
}) => {
  return await TxIm.sendTextGroupMessage(message, groupId);
};

export const sendCustomMessage = async ({
  type,
  message,
  userId,
}: {
  type: string;
  message: string;
  userId: string;
}) => {
  return await TxIm.sendCustomMessage(type, message, userId);
};

export const sendGroupCustomMessage = async ({
  type,
  message,
  groupId,
}: {
  type: string;
  message: string;
  groupId: string;
}) => {
  return await TxIm.sendGroupCustomMessage(type, message, groupId);
};
export interface Member {
  nickName: string;
  avatar: string;
  userId: String;
}
export interface Message extends Member {
  type: 'custom' | 'text';
  groupId?: string;
  content: string;
  userId: string;
}

export const getGroupMembers = async (groupId: string): Promise<Member[]> => {
  return await TxIm.getGroupMembers(groupId);
};

export const quit = async () => {
  return await TxIm.quit();
};
export const addMessageListener = (listener: (msg: Message) => void) => {
  txImEmitter.addListener('txim', (message: Message) => listener(message));
};
export const removeMessageListener = () => {
  txImEmitter.removeAllListeners('txim');
};
