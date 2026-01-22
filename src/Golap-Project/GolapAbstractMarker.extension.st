Extension { #name : 'GolapAbstractMarker' }

{ #category : '*Golap-Project' }
GolapAbstractMarker >> asJSON [

	^ { ('class' -> self class name asString) } asOrderedDictionary
]

{ #category : '*Golap-Project' }
GolapAbstractMarker class >> fromJSON: aDictionary [

	^ (self concreteClassFor: aDictionary) ifNotNil: [ :class |
		  class new fromJSON: aDictionary ]
]

{ #category : '*Golap-Project' }
GolapAbstractMarker >> fromJSON: aDictionary [

	^ self subclassResponsibility
]
