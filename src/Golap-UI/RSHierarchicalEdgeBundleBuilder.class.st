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

	| builder interaction |
	builder := self new.
	builder
		from: Collection subclasses using: [ :class | class subclasses ];
		build.
	interaction := RSPluggableLeftClickInteraction new action: [
			               :event
			               :shape |
			               ((SystemNavigation default allGlobalRefsOn:
				                 shape model name)
				                collect: [ :m | m methodClass ]
				                thenSelect: [ :class |
				                class inheritsFrom: Collection ]) asBag
				               doWithOccurrences: [ :class :weight |
						               builder
							               addEdgeFrom: class
							               to: shape model
							               do: [ :bspline |
									               bspline
										               markerEnd: (RSPolygon new points: {
														                (-3 @ 3 * weight).
														                (0 @ -3 * weight).
														                (3 @ 3 * weight) }) asMarker;
										               color: (shape color darker alpha: 0.8);
										               width: weight * 2;
										               yourself ] ].
			               event canvas signalUpdate ].
	builder canvas shapes do: [ :shape |
			(shape model isKindOf: Class) ifTrue: [
					shape @ interaction.
					builder canvas addShape: (RSLabel new
							 text: shape model name asString;
							 position: (shape centroid: 0.0)) ] ].
	builder canvas
		@ RSCanvasController;
		open
]

{ #category : 'examples' }
RSHierarchicalEdgeBundleBuilder class >> example1 [

	| builder |
	builder := self new.
	builder
		from: Collection subclasses using: [ :class | class subclasses ];
		build.
	builder canvas shapes do: [ :shape |
			(shape model isKindOf: Class) ifTrue: [
					builder canvas addShape: (RSLabel new
							 text: shape model name asString;
							 position: (shape centroid: 0.0)) ] ].
	SpJobPresenter new
		model: (Job block: [ :job |
						 | index |
						 index := 0.
						 job
							 min: index;
							 max: Collection allSubclasses size.
						 Collection allSubclassesDo: [ :dstClass |
								 | color |
								 color := (builder canvas shapes detect: [ :shape |
									           shape model == dstClass ]) color darker alpha: 0.8.
								 job value: (index := index + 1).
								 ((SystemNavigation default allGlobalRefsOn: dstClass name)
									  collect: [ :m | m methodClass ]
									  thenSelect: [ :srcClass |
									  srcClass inheritsFrom: Collection ]) asBag
									 doWithOccurrences: [ :srcClass :weight |
											 builder
												 addEdgeFrom: srcClass
												 to: dstClass
												 do: [ :bspline |
														 bspline
															 markerEnd: (RSPolygon new points: {
																			  (-3 @ 3 * weight).
																			  (0 @ -3 * weight).
																			  (3 @ 3 * weight) }) asMarker;
															 color: color;
															 width: weight * 2;
															 yourself ] ] ] ]);
		run.
	builder canvas
		@ RSCanvasController;
		open
]

{ #category : 'adding' }
RSHierarchicalEdgeBundleBuilder >> addEdgeBetween: anObject and: anotherObject do: aBlock [

	| controlPoints edge |
	controlPoints := self
		                 mergeControlPoints:
		                 (self controlPointsFor: anObject)
		                 and: (self controlPointsFor: anotherObject).
	controlPoints size < 4 ifTrue: [ ^ nil ].
	edge := RSUniformCubicBSpline new
		        controlPoints: controlPoints;
		        capRound;
		        yourself.
	aBlock value: edge.
	self canvas add: edge
]

{ #category : 'adding' }
RSHierarchicalEdgeBundleBuilder >> addEdgeFrom: anObject to: anotherObject do: aBlock [

	| controlPoints edge |
	controlPoints := self
		                 mergeControlPoints:
		                 (self controlPointsFor: anObject)
		                 and: (self controlPointsFor: anotherObject).
	controlPoints size < 4 ifTrue: [ ^ nil ].
	edge := RSUniformCubicBSpline new
		        controlPoints: controlPoints;
		        capRound;
		        markerEnd: (RSPolygon new
				         points: {
						         (-10 @ 10).
						         (0 @ -10).
						         (10 @ 10) };
				         asMarker);
		        yourself.
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
