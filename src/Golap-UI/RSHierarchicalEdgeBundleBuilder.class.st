Class {
	#name : 'RSHierarchicalEdgeBundleBuilder',
	#superclass : 'RSSunburstBuilder',
	#instVars : [
		'edges'
	],
	#category : 'Golap-UI-Roassal3',
	#package : 'Golap-UI',
	#tag : 'Roassal3'
}

{ #category : 'examples' }
RSHierarchicalEdgeBundleBuilder class >> example [

	| builder |
	builder := self new.
	builder
		from: Collection subclasses using: [ :class | class subclasses ];
		build.
	((SystemNavigation default allGlobalRefsOn: #Array)
		 collect: [ :m | m methodClass ]
		 thenSelect: [ :class | class inheritsFrom: Collection ]) asBag
		doWithOccurrences: [ :class :weight |
				builder
					addEdgeFrom: Array
					to: class
					do: [ :bspline |
							bspline
								color: Color red;
								width: weight ] ].
	builder canvas open
]

{ #category : 'adding' }
RSHierarchicalEdgeBundleBuilder >> addEdgeFrom: anObject to: anotherObject do: aBlock [

	| controlPoints edge |
	controlPoints := self
		                 mergeControlPoints:
		                 (self controlPointsFor: anObject)
		                 and: (self controlPointsFor: anotherObject).
	controlPoints size < 4 ifTrue: [ ^ nil ].
	edge := RSHEBSpline new controlPoints: controlPoints.
	aBlock value: edge.
	self canvas add: edge
]

{ #category : 'private' }
RSHierarchicalEdgeBundleBuilder >> controlPointsFor: anObject [

	^ (Array streamContents: [ :stream |
			   | shape |
			   shape := shapes
				            detect: [ :s | s model == anObject ]
				            ifNone: [ nil ].
			   [ shape notNil ] whileTrue: [
					   stream nextPut: (shape centroid: 0.0).
					   shape := shape sparent ] ]) reversed
]

{ #category : 'private' }
RSHierarchicalEdgeBundleBuilder >> mergeControlPoints: anArrayOfPoint and: anotherArrayOfPoint [

	| lastCommonPoint points1 points2  |
	lastCommonPoint := nil.
	points1 := OrderedCollection withAll: anArrayOfPoint.
	points2 := OrderedCollection withAll: anotherArrayOfPoint.
	[
		points1 notEmpty and: [
			points2 notEmpty and: [ points1 first = points2 first ] ] ]
		whileTrue: [
				lastCommonPoint := points1 first.
				points1 removeFirst.
				points2 removeFirst ].
	^ Array streamContents: [ :stream |
			  points1 reverseDo: [ :point | stream nextPut: point ].
			  lastCommonPoint ifNotNil: [ stream nextPut: lastCommonPoint ].
			  stream nextPutAll: points2 ]
]
