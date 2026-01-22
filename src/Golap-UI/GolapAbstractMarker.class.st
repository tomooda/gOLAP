Class {
	#name : 'GolapAbstractMarker',
	#superclass : 'Object',
	#category : 'Golap-UI-Graph',
	#package : 'Golap-UI',
	#tag : 'Graph'
}

{ #category : 'class access' }
GolapAbstractMarker class >> concreteClassFor: aDictionary [

	aDictionary at: 'class' ifPresent: [ :className |
			self allSubclassesDo: [ :subclass |
				subclass name asString = className ifTrue: [ ^ subclass ] ] ].
	^ nil
]

{ #category : 'testing' }
GolapAbstractMarker class >> isAbstract [

	^ self = GolapAbstractMarker
]

{ #category : 'accessing' }
GolapAbstractMarker >> activatedIn: aGolapItemList [

	^ self subclassResponsibility
]

{ #category : 'adding-removing' }
GolapAbstractMarker >> addNode: aGolapNode [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapAbstractMarker >> color [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapAbstractMarker >> icon [

	^ self subclassResponsibility
]

{ #category : 'testing' }
GolapAbstractMarker >> includesNode: aGolapNode [

	^ self includesNodeId: aGolapNode id
]

{ #category : 'testing' }
GolapAbstractMarker >> includesNodeId: anObject [

	^ self subclassResponsibility
]

{ #category : 'testing' }
GolapAbstractMarker >> isColorMarker [

	^ false
]

{ #category : 'accessing' }
GolapAbstractMarker >> queryString [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapAbstractMarker >> queryString: aString in: aGolapItemList [

	^ self subclassResponsibility
]

{ #category : 'private' }
GolapAbstractMarker >> regexFor: aString [

	| regex |
	regex := #( '\' '.' '[' ']' '(' ')' '!' '+' )
		         inject: aString
		         into: [ :p :special |
		         p copyReplaceAll: special with: '\' , special ].
	^ ((regex copyReplaceAll: '*' with: '.*')
		   copyReplaceAll: '?'
		   with: '[ -~]+') asRegex
]

{ #category : 'private' }
GolapAbstractMarker >> regexesFor: aString [

	^ (aString substrings: ',')
		  collect: [ :pattern |
				  pattern trim
					  ifNotEmpty: [ :pat |
							  | regex |
							  regex := #( '\' '.' '[' ']' '(' ')' '!' '+' )
								           inject: pat
								           into: [ :p :special |
								           p copyReplaceAll: special with: '\' , special ].
							  ((regex copyReplaceAll: '*' with: '.*')
								   copyReplaceAll: '?'
								   with: '[ -~]+') asRegex ]
					  ifEmpty: [ nil ] ]
		  thenSelect: #notNil
]

{ #category : 'adding-removing' }
GolapAbstractMarker >> removeNode: aGolapNode [

	^ self subclassResponsibility
]

{ #category : 'updating' }
GolapAbstractMarker >> updateIn: aGolapItemList [

	^ self subclassResponsibility
]
