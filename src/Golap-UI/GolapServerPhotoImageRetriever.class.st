Class {
	#name : 'GolapServerPhotoImageRetriever',
	#superclass : 'GolapPhotoImageRetriever',
	#instVars : [
		'golapServerUrl',
		'authenticateBlock',
		'imageServerUrl'
	],
	#category : 'Golap-UI-Graph',
	#package : 'Golap-UI',
	#tag : 'Graph'
}

{ #category : 'accessing' }
GolapServerPhotoImageRetriever >> authenticateBlock [

	^ authenticateBlock
]

{ #category : 'accessing' }
GolapServerPhotoImageRetriever >> authenticateBlock: aBlock [

	authenticateBlock := aBlock
]

{ #category : 'accessing' }
GolapServerPhotoImageRetriever >> golapServerUrl [

	^ golapServerUrl
]

{ #category : 'accessing' }
GolapServerPhotoImageRetriever >> golapServerUrl: aString [

	golapServerUrl := aString asZnUrl
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

{ #category : 'accessing' }
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
GolapServerPhotoImageRetriever >> retrieveImageNamed: aString [

	[
	| response |
	response := GolapHttpClient get: imageServerUrl / aString.
	response isSuccess ifTrue: [
		^ ImageReadWriter formFromStream: response entity readStream ] ]
		on: Error
		do: [ :ex |  ].
	^ nil
]
