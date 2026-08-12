Class {
	#name : 'RSHEBSpline',
	#superclass : 'RSAbstractControlPointsLine',
	#instVars : [
		'segments'
	],
	#category : 'Golap-UI-Roassal3',
	#package : 'Golap-UI',
	#tag : 'Roassal3'
}

{ #category : 'examples' }
RSHEBSpline class >> example [

	self new
		width: 5;
		controlPoints: {
				(0 @ 0).
				(100 @ 0).
				(100 @ -100).
				(200 @ -100).
				(200 @ 0).
				(300 @ 0) };
		inspect
]

{ #category : 'testing' }
RSHEBSpline >> basicIncludesPoint: aPoint [

	^ self segments anySatisfy: [ :bezier |
		  bezier basicIncludesPoint: aPoint ]
]

{ #category : 'visiting' }
RSHEBSpline >> buildPathOn: visitor [

	self segments do: [ :bezier | visitor buildBezierPath: bezier ]
]

{ #category : 'private' }
RSHEBSpline >> computeSegments [

	^ controlPoints size <= 4
		  ifTrue: [
				  { (RSBezier new
					   controlPoints: controlPoints;
					   yourself) } ]
		  ifFalse: [
				  Array streamContents: [ :stream |
						  | p0 p1 p2 p3 |
						  p0 := controlPoints at: 1.
						  p1 := controlPoints at: 2.
						  p2 := controlPoints at: 3.
						  p3 := controlPoints at: 4.
						  stream nextPut: (RSBezier new controlPoints: {
									   p0.
									   p1.
									   (p1 * (2.0 / 3.0) + (p2 / 3.0)).
									   (p1 / 6.0 + (p2 * 4.0 / 6.0) + (p3 / 6.0)) }).
						  (2 to: controlPoints size - 4) collect: [ :index |
								  p0 := p1.
								  p1 := p2.
								  p2 := p3.
								  p3 := controlPoints at: index + 3.
								  RSBezier new
									  controlPoints: {
											  (p0 / 6.0 + (p1 * (2.0 / 3.0)) + (p2 / 6.0)).
											  (p1 * (2.0 / 3.0) + (p2 / 3.0)).
											  (p1 / 3.0 + (p2 * (2.0 / 3.0))).
											  (p1 / 6.0 + (p2 * (2.0 / 3.0)) + (p3 / 6.0)) };
									  yourself ].
						  p0 := p1.
						  p1 := p2.
						  p2 := p3.
						  p3 := controlPoints last.
						  stream nextPut: (RSBezier new controlPoints: {
									   (p0 / 6.0 + (p1 * 4.0 / 6.0) + (p2 / 6.0)).
									   (p1 * (2.0 / 3.0) + (p2 / 3.0)).
									   p2.
									   p3 }) ] ]
]

{ #category : 'accessing' }
RSHEBSpline >> controlPoints: anArrayOfPoints [
	self
		assert: anArrayOfPoints isNotNil
		description: 'The argument can not be nil';
		assert: (anArrayOfPoints size >= 2)
		description: 'The array size must be greater than or equal to 2 points'.
	super controlPoints: anArrayOfPoints.
	segments := nil
]

{ #category : 'initialization' }
RSHEBSpline >> initialize [
	super initialize.
	controlPoints := { 0@0. 1@1 . 2@2. 3@3}
]

{ #category : 'accessing' }
RSHEBSpline >> lines [

	^ #(  ) join: (self segments collect: #lines)
]

{ #category : 'accessing' }
RSHEBSpline >> segments [

	^ segments ifNil: [ segments := self computeSegments ]
]
