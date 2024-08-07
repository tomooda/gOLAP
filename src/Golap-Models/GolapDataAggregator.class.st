Class {
	#name : 'GolapDataAggregator',
	#superclass : 'Object',
	#category : 'Golap-Models-Evaluators',
	#package : 'Golap-Models',
	#tag : 'Evaluators'
}

{ #category : 'instance creation' }
GolapDataAggregator class >> fromJSON: aDictionary [

	self allSubclassesDo: [ :subclass |
		subclass isAbstract not ifTrue: [
			aDictionary
				at: subclass tag
				ifPresent: [ :subtag | ^ subclass fromSubtag: subtag ] ] ].
	^ nil
]

{ #category : 'instance creation' }
GolapDataAggregator class >> fromSubtag: anArray [

	^ self subclassResponsibility
]

{ #category : 'testing' }
GolapDataAggregator class >> isAbstract [

	^ self = GolapDataAggregator
]

{ #category : 'accessing' }
GolapDataAggregator class >> tag [

	^ self subclassResponsibility
]

{ #category : 'converting' }
GolapDataAggregator >> asJSON [

	^ { (self tag -> self subtag) } asOrderedDictionary
]

{ #category : 'accessing' }
GolapDataAggregator >> column [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapDataAggregator >> subtag [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapDataAggregator >> tag [

	^ self class tag
]

{ #category : 'evaluating' }
GolapDataAggregator >> value: aCollectionOfDataSeries [

	^ self subclassResponsibility
]
