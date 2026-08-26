Class {
	#name : 'RSUniformCubicBSpline',
	#superclass : 'RSAbstractControlPointsLine',
	#instVars : [
		'segments'
	],
	#category : 'Golap-Visualization-HEB',
	#package : 'Golap-Visualization',
	#tag : 'HEB'
}

{ #category : 'examples' }
RSUniformCubicBSpline class >> example [

	self new
		width: 5;
		controlPoints: {
				(0 @ 0).
				(100 @ 0).
				(100 @ -100).
				(200 @ -100).
				(200 @ 0).
				(300 @ 0).
				(300 @ 100).
				(400 @ 100).
				(400 @ -100).
				(500 @ -100) };
		capRound;
		inspect
]

{ #category : 'testing' }
RSUniformCubicBSpline >> basicIncludesPoint: aPoint [

	^ self segments anySatisfy: [ :bezier |
		  bezier basicIncludesPoint: aPoint ]
]

{ #category : 'visiting' }
RSUniformCubicBSpline >> buildPathOn: visitor [

	self segments do: [ :bezier | visitor buildBezierPath: bezier ]
]

{ #category : 'private' }
RSUniformCubicBSpline >> computeSegments [

	^ controlPoints size <= 4
		  ifTrue: [
				  { (RSBezier new
					   controlPoints: controlPoints;
					   yourself) } ]
		  ifFalse: [
				  | beziers p0 p1 p2 p3 |
				  beziers := Array new: controlPoints size - 3.
				  p0 := controlPoints at: 1.
				  p1 := controlPoints at: 2.
				  p2 := controlPoints at: 3.
				  p3 := controlPoints at: 4.
				  beziers at: 1 put: (RSBezier new
						   controlPoints: {
								   p0.
								   p1.
								   (p1 / 3.0 + (p2 * 2 / 3.0)).
								   (p1 / 6.0 + (p2 * 4.0 / 6.0) + (p3 / 6.0)) };
						   yourself).
				  2 to: controlPoints size - 4 do: [ :index |
						  p0 := p1.
						  p1 := p2.
						  p2 := p3.
						  p3 := controlPoints at: index + 3.
						  beziers at: index put: (RSBezier new
								   controlPoints: {
										   (p0 / 6.0 + (p1 * (2.0 / 3.0)) + (p2 / 6.0)).
										   (p1 * (2.0 / 3.0) + (p2 / 3.0)).
										   (p1 / 3.0 + (p2 * (2.0 / 3.0))).
										   (p1 / 6.0 + (p2 * (2.0 / 3.0)) + (p3 / 6.0)) };
								   yourself) ].
				  p0 := p1.
				  p1 := p2.
				  p2 := p3.
				  p3 := controlPoints last.
				  beziers at: beziers size put: (RSBezier new
						   controlPoints: {
								   (p0 / 6.0 + (p1 * 4.0 / 6.0) + (p2 / 6.0)).
								   (p1 * (2.0 / 3.0) + (p2 / 3.0)).
								   p2.
								   p3 };
						   yourself).
				  beziers ]
]

{ #category : 'accessing' }
RSUniformCubicBSpline >> controlPoints: anArrayOfPoints [
	self
		assert: anArrayOfPoints isNotNil
		description: 'The argument can not be nil';
		assert: (anArrayOfPoints size >= 2)
		description: 'The array size must be greater than or equal to 2 points'.
	super controlPoints: anArrayOfPoints.
	segments := nil
]

{ #category : 'initialization' }
RSUniformCubicBSpline >> initialize [
	super initialize.
	controlPoints := { 0@0. 1@1 . 2@2. 3@3}
]

{ #category : 'accessing' }
RSUniformCubicBSpline >> lines [

	^ #(  ) join: (self segments collect: #lines)
]

{ #category : 'path' }
RSUniformCubicBSpline >> resetPath [

	super resetPath.
	segments := nil
]

{ #category : 'accessing' }
RSUniformCubicBSpline >> segments [

	^ segments ifNil: [ segments := self computeSegments ]
]
