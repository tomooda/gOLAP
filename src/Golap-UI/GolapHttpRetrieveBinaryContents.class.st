Class {
	#name : 'GolapHttpRetrieveBinaryContents',
	#superclass : 'ZnUrlOperation',
	#category : 'Golap-UI-CSV',
	#package : 'Golap-UI',
	#tag : 'CSV'
}

{ #category : 'accessing' }
GolapHttpRetrieveBinaryContents class >> operation [
	^ #retrieveBinaryContents
]

{ #category : 'accessing' }
GolapHttpRetrieveBinaryContents class >> schemes [
	^ #( #http #https )
]

{ #category : 'operations' }
GolapHttpRetrieveBinaryContents >> performOperation [
	"Download and return the HTTP(S) resource that url refers to.
	This will typically return a String or a ByteArray (see ZnClient>>#get:).
	If something goes wrong, an exception will be signalled."

	^ (ZnClient new
		   beOneShot;
		   enforceHttpSuccess: true;
		   get: self url) asByteArray
]
