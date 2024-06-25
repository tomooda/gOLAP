Class {
	#name : 'GolapFileRetrieveBinaryContents',
	#superclass : 'ZnUrlOperation',
	#category : 'Golap-Networking',
	#package : 'Golap-Networking'
}

{ #category : 'accessing' }
GolapFileRetrieveBinaryContents class >> operation [
	^ #retrieveBinaryContents
]

{ #category : 'accessing' }
GolapFileRetrieveBinaryContents class >> schemes [
	^ #( #file )
]

{ #category : 'operations' }
GolapFileRetrieveBinaryContents >> performOperation [
	"Download and return the FILE resource that url refers to.
	This will typically return a String or a ByteArray.
	If something goes wrong, an exception will be signalled."

	^ self url asFileReference binaryReadStreamDo: #contents
]
