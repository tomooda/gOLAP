Class {
	#name : #GolapVertexTest,
	#superclass : #TestCase,
	#instVars : [
		'vertex1',
		'vertex2',
		'vertex3'
	],
	#category : #'Golap-Models-Tests'
}

{ #category : #running }
GolapVertexTest >> setUp [

	vertex1 := GolapVertex
		           on:
		           (DataSeries withKeys: { 'value' } values: { 10 } name: 1)
		           name: 'v1'.
	vertex2 := GolapVertex
		           on:
		           (DataSeries withKeys: { 'value' } values: { 20 } name: 2)
		           name: 'v2'.
	vertex3 := GolapVertex
		           on:
		           (DataSeries withKeys: { 'value' } values: { 30 } name: 3)
		           name: 'v3'
]

{ #category : #tests }
GolapVertexTest >> testCopy [

	| copy |
	copy := vertex1 copy.
	self deny: copy identicalTo: vertex1.
	self assert: copy id equals: vertex1 id.
	self assert: copy name equals: vertex1 name.
	self assert: (copy at: 'value') equals: (vertex1 at: 'value').
	vertex1 data at: 'value' put: 0.
	self assert: (copy at: 'value') equals: 10
]

{ #category : #tests }
GolapVertexTest >> testDiff [

	self assert: (vertex1 at: 'value') equals: 10.
	self assert: (vertex2 at: 'value') equals: 20.
	vertex1 diff: vertex2.
	self assert: (vertex1 at: 'value') equals: -10.
	self assert: (vertex2 at: 'value') equals: 20
]
