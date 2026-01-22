Class {
	#name : 'GolapItemInfoRetriever',
	#superclass : 'Object',
	#instVars : [
		'photoimageRetrievers'
	],
	#category : 'Golap-UI-Retriever',
	#package : 'Golap-UI',
	#tag : 'Retriever'
}

{ #category : 'accessing' }
GolapItemInfoRetriever class >> classForJSON: aDictionary [

	| tag |
	tag := aDictionary at: 'tag' ifAbsent: [ ^ nil ].
	self allSubclassesDo: [ :subclass |
			(subclass isAbstract not and: [ subclass tag = tag ]) ifTrue: [
				^ subclass ] ].
	^ nil
]

{ #category : 'testing' }
GolapItemInfoRetriever class >> isAbstract [

	^ self = GolapItemInfoRetriever
]

{ #category : 'accessing' }
GolapItemInfoRetriever class >> tag [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapItemInfoRetriever >> availablePhotoimageRetrievers [

	^ ((Array streamContents: [ :stream |
		    GolapPhotoImageRetriever allSubclassesDo: [ :class |
			    class isAbstract ifFalse: [
				    (class for: self) ifNotNil: [ :retriever |
					    stream nextPut: retriever ] ] ] ]) asSortedCollection:
		   #order ascending) asArray
]

{ #category : 'defaults' }
GolapItemInfoRetriever >> defaultPhotoimageRetrievers [

	^ self availablePhotoimageRetrievers
]

{ #category : 'testing' }
GolapItemInfoRetriever >> hasPhotoImage [

	^ self photoimageRetrievers anySatisfy: #isAvailable
]

{ #category : 'accessing' }
GolapItemInfoRetriever >> photoimageFor: aGolapNode [

	self photoimageRetrievers do: [ :retriever |
		(retriever photoimageFor: aGolapNode) ifNotNil: [ :image | ^ image ] ].
	^ nil
]

{ #category : 'accessing' }
GolapItemInfoRetriever >> photoimageRetrievers [

	^ photoimageRetrievers ifNil: [
		  photoimageRetrievers := self defaultPhotoimageRetrievers ]
]

{ #category : 'accessing' }
GolapItemInfoRetriever >> photoimageRetrievers: anArrayOfGolapPhotoImageRetriever [

	photoimageRetrievers := anArrayOfGolapPhotoImageRetriever
]

{ #category : 'accessing' }
GolapItemInfoRetriever >> photoimageRetrieversConfigPresenter [

	^ GolapPhotoImageRetrieversPresenter on: self
]

{ #category : 'accessing' }
GolapItemInfoRetriever >> productDataFor: aGolapNode [

	^ self subclassResponsibility
]
