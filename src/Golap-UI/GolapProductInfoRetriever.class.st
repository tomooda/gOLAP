Class {
	#name : 'GolapProductInfoRetriever',
	#superclass : 'Object',
	#instVars : [
		'photoimageRetrievers'
	],
	#category : 'Golap-UI-Graph',
	#package : 'Golap-UI',
	#tag : 'Graph'
}

{ #category : 'accessing' }
GolapProductInfoRetriever class >> acceptsJSON: aDictionary [

	^ self isAbstract not and: [ aDictionary includesKey: self tag ]
]

{ #category : 'accessing' }
GolapProductInfoRetriever class >> classForJSON: aDictionary [

	self allSubclassesDo: [ :subclass |
		(subclass acceptsJSON: aDictionary) ifTrue: [ ^ subclass ] ].
	^ nil
]

{ #category : 'accessing' }
GolapProductInfoRetriever class >> fromJSON: aDictionary [

	^ (self classForJSON: aDictionary) ifNotNil: [ :subclass |
		  subclass new setFromJSON: aDictionary ]
]

{ #category : 'testing' }
GolapProductInfoRetriever class >> isAbstract [

	^ self = GolapProductInfoRetriever
]

{ #category : 'accessing' }
GolapProductInfoRetriever class >> tag [

	^ self subclassResponsibility
]

{ #category : 'converting' }
GolapProductInfoRetriever >> asJSON [

	^ self subclassResponsibility
]

{ #category : 'defaults' }
GolapProductInfoRetriever >> defaultPhotoimageRetrievers [

	^ self subclassResponsibility
]

{ #category : 'testing' }
GolapProductInfoRetriever >> hasPhotoImage [

	^ self photoimageRetrievers anySatisfy: #isAvailable
]

{ #category : 'accessing' }
GolapProductInfoRetriever >> photoimageFor: aGolapNode [

	self photoimageRetrievers do: [ :retriever |
		(retriever photoimageFor: aGolapNode) ifNotNil: [ :image | ^ image ] ].
	^ nil
]

{ #category : 'accessing' }
GolapProductInfoRetriever >> photoimageRetrievers [

	^ photoimageRetrievers ifNil: [
		  photoimageRetrievers := self defaultPhotoimageRetrievers ]
]

{ #category : 'accessing' }
GolapProductInfoRetriever >> productDataFor: aGolapNode [

	^ self subclassResponsibility
]

{ #category : 'private' }
GolapProductInfoRetriever >> setFromJSON: aDictionary [

	^ self subclassResponsibility
]
