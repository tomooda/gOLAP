Class {
	#name : #GolapEdgeTest,
	#superclass : #TestCase,
	#instVars : [
		'vertex1',
		'vertex2',
		'vertex3',
		'edge12',
		'edge23'
	],
	#category : #'Golap-Models-Tests'
}

{ #category : #running }
GolapEdgeTest >> setUp [

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
		           name: 'v3'.
	edge12 := vertex1
		          createEdgeTo: vertex2
		          data: (DataSeries withKeys: { 'value' } values: { 12 }).
	edge23 := vertex2
		          createEdgeTo: vertex3
		          data: (DataSeries withKeys: { 'value' } values: { 23 })
]

{ #category : #tests }
GolapEdgeTest >> testCopy [

	| copy |
	copy := edge12 copy.
	self deny: copy identicalTo: edge12.
	self assert: (copy at: 'value') equals: (edge12 at: 'value').
	edge12 data at: 'value' put: 0.
	self assert: (copy at: 'value') equals: 12
]

{ #category : #tests }
GolapEdgeTest >> testDiff [

	self assert: (edge12 at: 'value') equals: 12.
	self assert: (edge23 at: 'value') equals: 23.
	edge12 diff: edge23.
	self assert: (edge12 at: 'value') equals: -11.
	self assert: (edge23 at: 'value') equals: 23
]
