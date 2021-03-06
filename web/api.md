---
layout: page
title: Api
permalink: /api/
---
The endpoint for the API is: `https://api.cattlepi.com`.  
The API accepts `JSON` and produces `JSON`. All examples here use `curl` to show interactions with the API.  

## API Keys

All requests to the API must be accompanied by an API key. Requests without an API key will fail with a `400 Bad Request` response status.  

**The key must be passed in a header named 'X-Api-Key'**

To request an API key, enter your email address in following form:

<form action="https://aux.cattlepi.com/signup" method="post" enctype='application/json'>
  <div>
    <label for="email">Email: </label>
    <input name="email" id="email">
    <button>SignUp</button>
  </div>  
</form><br>
All the following examples use the demo `deadbeef` API key.  

Example request:
```bash
curl -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -H "X-Api-Key: deadbeef" \
     https://api.cattlepi.com/boot/testid/config
```

The corresponding response would be:
```json
{
  "initfs": {
    "url": "https://api.cattlepi.com/images/global/initramfs.tgz",
    "md5sum": "93a4eccacabdcce8eb5b8b68de6742cc"
  },
  "rootfs": {
    "url": "https://api.cattlepi.com/images/global/rootfs.sqsh",
    "md5sum": "c1d44c65d29af575b2f6685b6a91d2da"
  },
  "bootcode": "",
  "usercode": ""
}
```
## API Operations

### https://api.cattlepi.com/boot/{deviceid}/config
+ **`GET`**  
  This call is used to retrieve the boot configuration associated with a device.  

  **A note on isolation**: two users (i.e. different API keys) can have the same deviceid without experiencing a collision. The device ids live in the scope of the API key and there is no way of accessing the device configuration of another user if you don't know the API key. 

  Example:
  ```bash
  curl -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      -H "X-Api-Key: deadbeef" \
      https://api.cattlepi.com/boot/testid/config
  ```
  with response: 
  ```json
  {
    "initfs": {
      "url": "https://api.cattlepi.com/images/global/initramfs.tgz",
      "md5sum": "93a4eccacabdcce8eb5b8b68de6742cc"
    },
    "rootfs": {
      "url": "https://api.cattlepi.com/images/global/rootfs.sqsh",
      "md5sum": "c1d44c65d29af575b2f6685b6a91d2da"
    },
    "bootcode": "",
    "usercode": ""
  }
  ```

  **A note on a special deviceid**: The device id **`default`** is a special id. Whenever you do a get with a deviceid that was not specified before (through a previous POST for that device id), if a device configuration was specified for the `default` deviceid, you will receive this configuration. **Why?** This allows you to dynamically boot your devices without having to specify them apriori. You can maintain one device configuration for all your devices, or you can use the default one as a method of discovering and configuring them.  

+ **`POST`**  
  This call is used to update the boot configuration associated with a device.

  Example:
  ```bash
  curl -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      -H "X-Api-Key: deadbeef" \
      -X POST -d '{"rootfs":{"url":"https://api.cattlepi.com/images/global/rootfs.sqsh","md5sum":"c1d44c65d29af575b2f6685b6a91d2da"},"initfs":{"url":"https://api.cattlepi.com/images/global/initramfs.tgz","md5sum":"93a4eccacabdcce8eb5b8b68de6742cc"}}' \
      https://api.cattlepi.com/boot/otherdevice/config
  ```

  A successful response would be:
  ```json
  {"status":"ok"}
  ```

  The structure of the json that is passed in is as follows:
  ```
    {
      "initfs": {
        "url": <<path to the initfs image : string>>,
        "md5sum": <<md5 sum of the initfs image : string>>
      },
      "rootfs": {
        "url": <<path to the rootfs image : string>>,
        "md5sum": <<md5 sum of the rootfs image : string>>
      },
      "bootcode": <<base64 endcoded shell script : string >>,
      "usercode": <<base64 endcoded shell script : string >>,
      "config": <<additional free form configuration : valid json>>
    }
  ```
  The API will **ignore** any keys that do not match the above. Any keys that are not specified will be set to an empty string (or empty json in case of the config)

  **Another note on isolation**: The demo api key `deadbeef` has this method disabled. Your individually requested key will not have this limitation.

+ **`DELETE`**  
  This call is used to remove the boot configuration associated with a device.

### https://api.cattlepi.com/images/{space}/filename
+ **`GET`**  
  Used to download images hosted by api.cattlepi.com
  The only valid values for the {space} path parameter are: `global` and the user's API key.

  Example request:
  ```bash
  curl -v -H "X-Api-Key: deadbeef" \
      https://api.cattlepi.com/images/global/initramfs.tgz
  ```

  At this iteration this will most likely result in a redirection (302) and the location that you will be pointed to is a temporary AWS S3 download. You will need to follow the redirect and download the image before the link expires.

  A sample response:
  ```bash
  < HTTP/1.1 302 Found
  < Date: Tue, 26 Jun 2018 05:20:55 GMT
  < Content-Type: application/json
  < Content-Length: 0
  < Connection: keep-alive
  < x-amzn-RequestId: b3ae5e43-7900-11e8-9b7b-4d5b77c8057d
  < x-amz-apigw-id: JE0AsH3yvHcFo7w=
  < Location: https://cattlepi-images.s3.amazonaws.com/global/initramfs.tgz?AWSAccessKeyId=ASIAIK4I7NAAVTVCQ6UA&Signature=a7u87tfMnC3N0h6h8rLJigSc3BM%3D&x-amz-security-token=FQoDYXdzEJ7%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaDMoDCHuiWoGyR2XCpCKNAimobryo74h6%2BjdDsKl4DsWOtXQsKkLJE%2F4aXHHrBGtd9UFfk%2FbdNj10MryFenYB%2BCWfKQGmIOC1ouEMR0GIlsZb2X3NjGNhagOO%2FIpFm4auqgect3P69fkQqNAOSPB40EWXldnJTjDcXoc9th4ZRhjn3rmOftd4w7VdoHtKU3AT2CxnykldrF3cAviMig8FX2DJU%2F7nF8tfM3h46%2BhG4z6iKr9W76WUGWAmF69rFpF7XfZZhqTcdnj5OTNZ4%2BjpTnokhi88X5%2BB8489%2FIORyRwcCIdSJIaHQ2xI%2Fa7GKZpSPzaYrdXP7gHCeQOVW0XxDTgqRqqi1sNNo42U2RKbMuwE2pShm6nUwmBpi0lAKJOax9kF&Expires=1529990485
  < X-Amzn-Trace-Id: Root=1-5b31cd37-a90fd0188f6c12685705b278
  ```
  At this point in time we don't give you the option to upload your own images. You will have to host and serve your own images or use the [prebuild images]({% link images.md %}) we offer.

### https://api.cattlepi.com/track
Tracking allows to retrieve information your devices have reported and to identify devices that are active on the network. A device is considered active if it was seen within the last 3 months.  

+ **`GET`**  
  Used to get a list of all your devices
  Example request:
  ```bash
    curl -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      -H "X-Api-Key: deadbeef" \
      https://api.cattlepi.com/track  
  ```
  A sample response:
  ```bash
  ["b8:27:eb:6c:33:e2","default"]
  ```

### https://api.cattlepi.com/track/{deviceid}
+ **`GET`**  
  Used to get the log entries associated with a device
  Example request:
  ```bash
    curl -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      -H "X-Api-Key: deadbeef" \
      https://api.cattlepi.com/track/b8:27:eb:6c:33:e2
  ```
  A sample response:
  ```bash
  [
    "2018-08-05 03:23:37.625624 BOOT GET",
    "2018-08-05 04:38:28.549549 BOOT GET"
  ]
  ```

  **Important**: The api will keep a maximum number of **10 entries per device** (oldest entry gets removed if you already have 10 and want to add another). Each entry can be at most **256 chars in length**. Also as you observe from the example above, the api tracks records for whenever the device configuration is retrieved or updated automatically (BOOT GET above)

+ **`POST`**  
  Used to add a new log entry for the specified device.   
  Example request:
  ```bash
  curl -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      -H "X-Api-Key: deadbeef" \
      -X POST -d '{"info":"the bird is the word"}' \
      https://api.cattlepi.com/track/b8:27:eb:6c:33:e2
  ```
  With a sample response of:
  ```bash
  {"status": "ok"}
  ```

  After the update, a GET on `https://api.cattlepi.com/track/b8:27:eb:6c:33:e2` would result in 
  ```bash
    [
      "2018-08-05 03:23:37.625624 BOOT GET",
      "2018-08-05 04:38:28.549549 BOOT GET",
      "2018-08-05 04:46:41.767841 the bird is the word"
    ]
  ```

  Please notice the timestamp (UTC) that was automatically added. The timestamp also counts towards the 256 character limit. Also notice that the tracking information is append only (i.e. you cannot delete from it)

## API Quota Limits

Ideally we would like the usage of this API to be free. We hope that, for the vast majority of users and use cases, this will be the case. For the exceptional cases we do have quotas on the number of API calls that you can make. This ensures that our running costs do not spiral out of control. 

The limits are as follows:
 * `GET  https://api.cattlepi.com/boot/{deviceid}/config`: maximum of **60** requests per **hour**
 * `POST https://api.cattlepi.com/boot/{deviceid}/config`: maximum of **10** requests per **hour**
 * `DELETE https://api.cattlepi.com/boot/{deviceid}/config`: maximum of **10** requests per **hour**
 * `GET https://api.cattlepi.com/images/{space}/filename`: maximum of **10** requests per **month**
 * `GET https://api.cattlepi.com/track`: maximum of **300** requests per **hour**
 * `GET https://api.cattlepi.com/track/{deviceid}`: maximum of **300** requests per **hour**
 * `POST https://api.cattlepi.com/track/{deviceid}`: maximum of **120** requests per **hour**
 
Unused requests **do not accumulate**.

What this means is:
 * if you had a single device, and rebooted it each minute, you would not hit the API limits
 * if you had to alter or update your configuration, you could make ten updates per hour _at the most_. Or you could update the configuration for ten devices in one hour. Again, this should not constrain you (but do reach out if you need this to be higher)
 * the ten requests per month for downloading images may seem a bit draconic at first. The reasoning is as follows: the images themselves are large and the downloads will consume real bandwidth. If you have less than five devices, this quota should easily suit your needs (recall that the images are cached locally - this is the main reason why we want to cache them). If you need to get around this you could store the images somewhere your devices can access (intra- or internet), and point the config to those images. Alternatively, we are open to learning more about your use case (and perhaps helping you with the additional bandwidth)

We do not currently support uploading your custom images through our API. However, this is on our strategic roadmap. Again, we encourage you to reach out and tell us about your use case.
