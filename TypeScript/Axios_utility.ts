import axios, { AxiosRequestConfig } from "axios"
import { IApiResponse } from './models/apiResponse';
import { IApiRequest } from './models/ApiRequest';

export class ApiUtility {
    getData(request: IApiRequest, callback: (response: IApiResponse) => void) {
        let resp: IApiResponse = {};
        if (request.url !== "") {
            axios.get(request.url, {
                params: request.parameters,
            })
                .then(response => {
                    if (response.data) {
                        resp.success = true;
                        resp.data = response.data;
                    } else {

                        resp.message = "No Data";
                    }
                    return callback(resp);
                })
                .catch(e => {
                    resp.message = e;
                    resp.success = false;
                    return callback(resp);
                });
        } else {
            resp.message = "Request Url is empty";
            return callback(resp);
        }

    };
    postData(request: IApiRequest, callback: (response: IApiResponse) => void) {
        let resp: IApiResponse = {};

        if (request.url !== "") {

            var data:string|null = null;
            if (request.parameters) {
                data = JSON.stringify(request.parameters);
            }

            var config: AxiosRequestConfig = {
                method: 'post',
                url: request.url,
                headers: {
                    'Content-Type': 'application/json'
                },
                data: data
            };
            axios(config)
                .then(response => {
                    if (response.data) {
                        resp.success = true;
                        resp.data = response.data;
                    } else {
                        resp.success = true;
                        resp.message = "No Data";
                    }
                    return callback(resp);
                })
                .catch(e => {
                    resp.message = e;
                    resp.success = false;
                    return callback(resp);
                });
        } else {
            resp.success = false;
            resp.message = "Request Url is empty";
            return callback(resp);
        }

    };

    putData(request: IApiRequest, callback: (response: IApiResponse) => void) {
        let resp: IApiResponse = {};


        if (request.url !== "") {
            axios.put(request.url, request.parameters)
                .then(response => {
                    if (response.data) {
                        resp.success = true;
                        resp.data = response.data;
                    } else {
                        resp.success = true;
                        resp.message = "No Data";
                    }
                    return callback(resp);
                })
                .catch(e => {
                    resp.message = e;
                    resp.success = false;

                    return callback(resp);
                });
        } else {
            resp.success = false;
            resp.message = "Request Url is empty";
            return callback(resp);
        }

    };

    deleteData(request: IApiRequest, callback: (response: IApiResponse) => void) {
        let resp: IApiResponse = {};
        if (request.url !== "") {
            axios.delete(request.url, {
                data: {
                    requestItem: request.parameters
                }
            })
                .then(response => {
                    if (response.data) {
                        resp.success = true;
                        resp.data = response.data;
                    } else {
                        resp.success = true;
                        resp.message = "No Data";
                    }
                    return callback(resp);
                })
                .catch(e => {
                    resp.message = e;
                    resp.success = false;

                    return callback(resp);
                });
        } else {
            resp.success = false;
            resp.message = "Request Url is empty";
            return callback(resp);
        }

    };
}