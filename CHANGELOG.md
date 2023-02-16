## 5.3.1 - 2023-02-16
* upgrade `dio` version 

## 5.3.0 - 2023-01-31
`Feature`
* add `appendObject` method to append object

## 5.2.0 - 2023-01-30
`Feature`
* add content-type base on the filename
* add customize header in `PutRequestOption` and `PutRequestOption`

## 5.1.5+1 - 2023-01-14
* fix the format

## 5.1.5 - 2023-01-14
`Feature`
* add copyObject feature that can copy object from different bucket

`Optimize`
* remove `mime_type` dependencies

## 5.1.4 - 2023-01-09
`Feature`
* add CancelToken that can cancel the request

## 5.1.3+3 - 2023-01-07
`Docs`
* update the docs

## 5.1.3+2 - 2023-01-07
`Docs`
* use english colon to avoid link issue in pub website

## 5.1.3+1 - 2023-01-07
`Docs`
* use span instead of div in docs

## 5.1.3 - 2023-01-07
`Docs`
* fix the link style when anchor include chinese words

## 5.1.2 - 2023-01-07
`Docs`
* fix the link style in docs

## 5.1.1+1 - 2023-01-07
`Docs`
* fix table style in docs

## 5.1.1 - 2023-01-07
`Optimize`
* optimize the docs
* refactor code

## 5.1.0 - 2023-01-07
`Breaking Change`

**In PutRequestOption**
* `acl` => `aclModel`
* `isOverwrite` => `override`

`Test`
* add unit test

## 5.0.4 - 2023-01-06
* reorder the example in readme
* add storageType parameter when upload file

## 5.0.3 - 2023-01-06
* correct the example in readme
* enable the Dio customize
* add acl parameter when upload file

## 5.0.2 - 2023-01-05
* fix the typo AclMode
* fix the onSendProgress callback in putObject

## 5.0.1 - 2022-12-26
* [web] fix the unsafe header `Date` issue

## 5.0.0 - 2022-12-16
`Breaking Change`: 
* putObject use PutRequestOption instead of multiple parameters
* pubObjectFile use PutRequestOption instead of multiple parameters


`New Features`: 
* get object metadata
* get regions information
* bucket acl support
* bucket policy support


## 4.1.7 - 2022-12-15
* upload multiple local files

## 4.1.6 - 2022-12-15
* fix the upload issue

## 4.1.5 - 2022-12-13
* upload local file

## 4.1.4 - 2022-12-13
* change the upload data use stream

## 4.1.3 - 2022-11-25
* list buckets

## 4.1.2 - 2022-11-25
* update the docs

## 4.1.1 - 2022-11-25
* fix the issue when pass parameters in listObjects

## 4.1.0 - 2022-11-25
* get bucket info
* get bucket stat

## 4.0.0 - 2022-11-25
* list all objects from bucket

## 3.1.3 - 2022-11-21
* handle the special character +

## 3.1.2 - 2022-11-17
* documentation

## 3.1.1 - 2022-11-17
* add multiple signed urls feature

## 3.1.0 - 2022-11-17
* add signed url feature

## 3.0.2 - 2022-10-18
* export the AssetEntity

## 3.0.1 - 2022-10-18
* update the document

## 3.0.0 - 2022-10-18
* add progress callback when upload files
* add progress callback when download files

## 2.0.3 - 2022-10-10
* change return type of tokenGetter to Future

## 2.0.2 - 2022-10-10
* update the document

## 2.0.1 - 2022-09-27
* update the document

## 2.0.0 - 2022-09-27
* add batch upload object
* add batch delete object

## 1.0.5 - 2022-08-06
* add README_ZH.md

## 1.0.4 - 2022-05-22
* code improvement for the nullable type

## 1.0.3 - 2022-05-14
* update the license to MIT

## 1.0.2 - 2022-05-14
* upgrade flutter_lint version
* add specified type instead of var

## 1.0.1 - 2022-03-22
* documentation of the changelog and readme

## 1.0.0 - 2022-03-22
* Add customize way to get sts information

## 0.1.1 - 2022-03-22
* Enable Log output in the dio

## 0.1.0 - 2022-03-21
* Correct the document

## 0.0.9 - 2022-03-21
* Enable delete object fromm oss

## 0.0.8 - 2022-03-21
* Code format and documentation

## 0.0.7 - 2022-03-20
* Change the LICENSE to use BSD 3-Clause

## 0.0.6 - 2022-03-20
* Add example and comments in code

## 0.0.5 - 2022-03-20
* Enable download object from oss

## 0.0.4 - 2022-03-20
* format the README files

## 0.0.3 - 2022-03-19
* Add README files

## 0.0.2 - 2022-03-19
* Enable put object to oss
* Enable get object from oss

## 0.0.1 - 2022-03-19
* First release.