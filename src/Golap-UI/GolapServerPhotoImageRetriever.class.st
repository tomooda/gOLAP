Class {
	#name : 'GolapServerPhotoImageRetriever',
	#superclass : 'GolapPhotoImageRetriever',
	#instVars : [
		'golapServerUrl',
		'authenticateBlock',
		'imageServerUrl'
	],
	#category : 'Golap-UI-Retriever',
	#package : 'Golap-UI',
	#tag : 'Retriever'
}

{ #category : 'instance creation' }
GolapServerPhotoImageRetriever class >> for: aGolapItemInfoRetriever [

	^ [
	  self new
		  golapServerUrl: aGolapItemInfoRetriever golapServerUrl;
		  authenticateBlock: aGolapItemInfoRetriever authenticateBlock;
		  imageServerUrl: aGolapItemInfoRetriever imageRepositoryUrl;
		  yourself ]
		  on: Error
		  do: [ :ex | ex return: nil ]
]

{ #category : 'accessing' }
GolapServerPhotoImageRetriever class >> tag [

	^ 'server'
]

{ #category : 'accessing' }
GolapServerPhotoImageRetriever >> authenticateBlock [

	^ authenticateBlock
]

{ #category : 'accessing' }
GolapServerPhotoImageRetriever >> authenticateBlock: aBlock [

	authenticateBlock := aBlock
]

{ #category : 'private' }
GolapServerPhotoImageRetriever >> commit: copy [

	golapServerUrl := copy golapServerUrl.
	authenticateBlock := copy authenticateBlock.
	imageServerUrl := copy imageServerUrl
]

{ #category : 'user interface' }
GolapServerPhotoImageRetriever >> configPresenter [

	^ GolapServerPhotoImageRetrieverPresenter on: self
]

{ #category : 'accessing' }
GolapServerPhotoImageRetriever >> golapServerUrl [

	^ golapServerUrl
]

{ #category : 'accessing' }
GolapServerPhotoImageRetriever >> golapServerUrl: aString [

	golapServerUrl := aString asZnUrl
]

{ #category : 'testing' }
GolapServerPhotoImageRetriever >> hasConfigPresenter [

	^ true
]

{ #category : 'accessing' }
GolapServerPhotoImageRetriever >> imageServerUrl [

	^ imageServerUrl
]

{ #category : 'accessing' }
GolapServerPhotoImageRetriever >> imageServerUrl: aString [

	imageServerUrl := aString asZnUrl
]

{ #category : 'testing' }
GolapServerPhotoImageRetriever >> isAvailable [

	^ golapServerUrl notNil and: [ imageServerUrl ] notNil
]

{ #category : 'enumerating' }
GolapServerPhotoImageRetriever >> namesFor: aGolapNode do: aBlock [

	([
	 (GolapHttpClient
		  post: golapServerUrl
		  data: (ZnEntity json:
				   '{"nodeimage": {"itemVal": "' , aGolapNode id asString
				   , '"},"deadlineTimer":0}')
		  authenticateBlock: self authenticateBlock) entity contents trim
		 lines allButFirst: 2 ]
		 on: Error
		 do: [ :ex | ^ self ]) do: aBlock
]

{ #category : 'accessing' }
GolapServerPhotoImageRetriever >> order [

	^ 10
]

{ #category : 'accessing' }
GolapServerPhotoImageRetriever >> retrieveImageNamed: aString [

	[
	| response |
	response := GolapHttpClient get: imageServerUrl / aString.
	response isSuccess ifTrue: [
		^ ImageReadWriter formFromStream: response entity readStream ] ]
		on: Exception
		do: [ :ex |  ].
	^ nil
]

{ #category : 'accessing' }
GolapServerPhotoImageRetriever >> shortDescription [

	^ 'gOLAPサーバ ' , (golapServerUrl ifNil: [ '(未設定)' ]) asString
	  , ' 画像サーバ' , (imageServerUrl ifNil: [ '(未設定)' ]) asString
]
