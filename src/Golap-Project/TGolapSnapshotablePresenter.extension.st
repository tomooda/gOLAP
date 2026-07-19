Extension { #name : 'TGolapSnapshotablePresenter' }

{ #category : '*Golap-Project' }
TGolapSnapshotablePresenter >> asJSON [

	^ self subclassResponsibility
]

{ #category : '*Golap-Project' }
TGolapSnapshotablePresenter >> basicAsJSON [

	^ {
		  ('class' -> self class name asString).
		  ('window' -> self windowJSON).
		  ('bounds' -> self boundsJSON) } asOrderedDictionary
]

{ #category : '*Golap-Project' }
TGolapSnapshotablePresenter >> basicFromJSON: aDictionary [

	| bounds |
	aDictionary
		at: 'bounds' ifPresent: [ :array |
				bounds := array first @ array second corner:
						          array third @ array fourth ];
		at: 'window'
		ifPresent: [ :string | self fromWindowJSON: string bounds: bounds ]
]

{ #category : '*Golap-Project' }
TGolapSnapshotablePresenter >> boundsJSON [

	self window ifNotNil: [ :window |
			window withAdapterDo: [ :a |
					a widgetDo: [ :w |
							| bounds |
							bounds := w fullBounds.
							^ {
								  bounds origin x.
								  bounds origin y.
								  bounds corner x.
								  bounds corner y } ] ] ].
	^ nil
]

{ #category : '*Golap-Project' }
TGolapSnapshotablePresenter >> fromJSON: aDictionary [

	^ self subclassResponsibility
]

{ #category : '*Golap-Project' }
TGolapSnapshotablePresenter >> fromWindowJSON: aString bounds: aRectangle [

	[
		aString = 'open' ifTrue: [ ^ (self openBounds: aRectangle) open ].
		aString = 'minimized' ifTrue: [
				^ self asWindow
					  open;
					  minimize ].
		aString = 'maximized' ifTrue: [
				^ (self openBounds: aRectangle)
					  maximize;
					  open ].
		aRectangle ifNotNil: [
				^ self asWindow
					  initialPosition: aRectangle origin;
					  initialExtent: aRectangle extent ].
		^ nil ] ensure: [
			self currentWorld submorphs do: [ :morph |
					(morph model isKindOf: SpModalWindowPresenter) ifTrue: [
						morph comeToFront ] ] ]
]

{ #category : '*Golap-Project' }
TGolapSnapshotablePresenter >> windowJSON [

	self window ifNotNil: [ :window |
			window isMinimized ifTrue: [ ^ 'minimized' ].
			window isMaximized ifTrue: [ ^ 'maximized' ].
			window isOpen ifTrue: [ ^ 'open' ] ].
	^ 'closed'
]
