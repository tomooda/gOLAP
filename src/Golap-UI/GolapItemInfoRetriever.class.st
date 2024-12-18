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
GolapItemInfoRetriever class >> acceptsJSON: aDictionary [

	^ self isAbstract not and: [ aDictionary includesKey: self tag ]
]

{ #category : 'accessing' }
GolapItemInfoRetriever class >> classForJSON: aDictionary [

	self allSubclassesDo: [ :subclass |
		(subclass acceptsJSON: aDictionary) ifTrue: [ ^ subclass ] ].
	^ nil
]

{ #category : 'accessing' }
GolapItemInfoRetriever class >> fromJSON: aDictionary [

	^ (self classForJSON: aDictionary) ifNotNil: [ :subclass |
		  subclass new setFromJSON: aDictionary ]
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
GolapItemInfoRetriever >> allAvailablePhotoimageRetrievers [

	^ self availablePhotoimageRetrievers
]

{ #category : 'converting' }
GolapItemInfoRetriever >> asJSON [

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

{ #category : 'private' }
GolapItemInfoRetriever >> setFromJSON: aDictionary [

	^ self subclassResponsibility
]
