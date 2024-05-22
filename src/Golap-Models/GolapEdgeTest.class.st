Class {
	#name : 'GolapEdgeTest',
	#superclass : 'TestCase',
	#instVars : [
		'edge12',
		'edge23',
		'node1',
		'node2',
		'node3'
	],
	#category : 'Golap-Models-Tests',
	#package : 'Golap-Models',
	#tag : 'Tests'
}

{ #category : 'running' }
GolapEdgeTest >> setUp [

	node1 := GolapNode
		           on:
		           (DataSeries withKeys: { 'value' } values: { 10 } name: 1)
		           name: 'v1'.
	node2 := GolapNode
		           on:
		           (DataSeries withKeys: { 'value' } values: { 20 } name: 2)
		           name: 'v2'.
	node3 := GolapNode
		           on:
		           (DataSeries withKeys: { 'value' } values: { 30 } name: 3)
		           name: 'v3'.
	edge12 := node1
		          createEdgeTo: node2
		          data: (DataSeries withKeys: { 'value' } values: { 12 }).
	edge23 := node2
		          createEdgeTo: node3
		          data: (DataSeries withKeys: { 'value' } values: { 23 })
]

{ #category : 'tests' }
GolapEdgeTest >> testCopy [

	| copy |
	copy := edge12 copy.
	self deny: copy identicalTo: edge12.
	self assert: (copy at: 'value') equals: (edge12 at: 'value').
	edge12 data at: 'value' put: 0.
	self assert: (copy at: 'value') equals: 12
]

{ #category : 'tests' }
GolapEdgeTest >> testDiff [

	self assert: (edge12 at: 'value') equals: 12.
	self assert: (edge23 at: 'value') equals: 23.
	edge12 diff: edge23.
	self assert: (edge12 at: 'value') equals: -11.
	self assert: (edge23 at: 'value') equals: 23
]
