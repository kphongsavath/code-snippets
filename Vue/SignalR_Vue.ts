import { ApiUtility } from "@/utils/apiUtility";
import { HubConnectionBuilder, LogLevel } from '@microsoft/signalr';
import _Vue from "vue";

export function UserHub(Vue: typeof _Vue, options?: any): void {

    const userHubConnection = new HubConnectionBuilder()
        .withUrl(`${process.env.VUE_APP_CRAP_HUB_URL}/user-hub`)
        .withAutomaticReconnect({
            nextRetryDelayInMilliseconds: retryContext => {
                if (retryContext.elapsedMilliseconds < 60000) {
                    // If we've been reconnecting for less than 60 seconds so far,
                    // wait between 0 and 10 seconds before the next reconnect attempt.
                    return Math.random() * 10000;
                } else {
                    // If we've been reconnecting for more than 60 seconds so far, stop reconnecting.
                    return null;
                }
            }
        })
        .configureLogging(LogLevel.Information)
        .build();

    const _apiUtility = new ApiUtility();

    let startedPromise: Promise<void>;
    function start() {
        startedPromise = userHubConnection.start()
            .catch(err => {
                console.error('Failed to connect with User hub', err)
                return new Promise((resolve, reject) =>
                    setTimeout(() => start().then(resolve).catch(reject), 5000))
            })
        return startedPromise
    }

    const userHub = new _Vue()
    Vue.prototype.$userHub = userHub;

    userHubConnection.onclose(() => start());

    userHubConnection.on('UserConnectionsChanged', () => {
        userHub.$emit('connections-changed');
    });
    userHubConnection.on('ConnectionCheck', () => {
        userHub.$emit('connection-check');
    });

    Vue.prototype.$userHub.connection = userHubConnection;
    start();
        //.then(() => {
        //    _apiUtility.postData({ url: `${process.env.VUE_APP_CRAP_API_URL}/user/userConnected` }, (resp) => { });
        //});
}