Extension { #name : 'RSMorphicHost' }

{ #category : '*Golap-UI' }
RSMorphicHost >> dirtyRectangle: aRectangleOrNil [

	dirtyRectangle := aRectangleOrNil.
	dirtyRectangle ifNotNil: [ :dRect |
		dirtyRectangle := dRect intersect: canvas visibleRectangle ]
]
