Extension { #name : 'RSBox' }

{ #category : '*Golap-UI' }
RSBox >> origin: aPoint corner: anotherPoint [

	| oldExtent oldPosition delta |
	self assert: aPoint isPoint.
	self assert: anotherPoint isPoint.
	oldExtent := baseRectangle extent.
	oldPosition := baseRectangle center.
	delta := self hasBorder
		         ifTrue: [ border width / 2.0 ]
		         ifFalse: [ 0.0 ].
	baseRectangle := Rectangle
		                 origin: (aPoint min: anotherPoint) + delta
		                 corner: (aPoint max: anotherPoint) - delta.
	self
		resetBBox;
		resetPath.
	self announce: [
			RSExtentChangedEvent new
				shape: self;
				oldExtent: oldExtent;
				newExtent: baseRectangle extent ].
	self announce: [
			RSPositionChangedEvent new
				shape: self;
				oldExtent: oldPosition;
				newExtent: baseRectangle center ]
]
