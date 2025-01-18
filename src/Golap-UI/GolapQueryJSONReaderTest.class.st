Class {
	#name : 'GolapQueryJSONReaderTest',
	#superclass : 'TestCase',
	#category : 'Golap-UI-Tests',
	#package : 'Golap-UI',
	#tag : 'Tests'
}

{ #category : 'tests' }
GolapQueryJSONReaderTest >> testFromString [

	| json |
	json := GolapQueryJSONReader fromString:
		        '{"x": 1, "y" : {"y1": 2, "y2": 3}}'.
	self assert: json isHiDeSyntaxTree.
	self assert: (json at: 'x') equals: 1.
	self assert: (json at: 'y') isHiDeSyntaxTree.
	self assert: ((json at: 'y') at: 'y1') equals: 2.
	self assert: ((json at: 'y') at: 'y2') equals: 3
]
