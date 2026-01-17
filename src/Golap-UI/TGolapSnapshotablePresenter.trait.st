Trait {
	#name : 'TGolapSnapshotablePresenter',
	#category : 'Golap-UI-Snapshot',
	#package : 'Golap-UI',
	#tag : 'Snapshot'
}

{ #category : 'instance creation' }
TGolapSnapshotablePresenter classSide >> fromJSON: aDictionary [

	^ self new fromJSON: aDictionary
]

{ #category : 'snapshot' }
TGolapSnapshotablePresenter >> asJSON [

	^ self subclassResponsibility
]

{ #category : 'snapshot' }
TGolapSnapshotablePresenter >> basicAsJSON [

	^ {
		  ('class' -> self class name asString).
		  ('window' -> self windowJSON).
		  ('bounds' -> self boundsJSON) } asOrderedDictionary
]

{ #category : 'snapshot' }
TGolapSnapshotablePresenter >> basicFromJSON: aDictionary [

	| bounds |
	aDictionary
		at: 'bounds' ifPresent: [ :array |
				bounds := array first @ array second corner:
						          array third @ array fourth ];
		at: 'window'
		ifPresent: [ :string | self fromWindowJSON: string bounds: bounds ]
]

{ #category : 'snapshot' }
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

{ #category : 'snapshot' }
TGolapSnapshotablePresenter >> fromJSON: aDictionary [

	^ self subclassResponsibility
]

{ #category : 'snapshot' }
TGolapSnapshotablePresenter >> fromWindowJSON: aString bounds: aRectangle [

	aString = 'open' ifTrue: [ ^ self openBounds: aRectangle ].
	aString = 'minimized' ifTrue: [
			^ (self openBounds: aRectangle)
				  minimize;
				  open ].
	aString = 'maximized' ifTrue: [
			^ (self openBounds: aRectangle)
				  maximize;
				  open ].
	aRectangle ifNotNil: [
			^ self asWindow
				  initialPosition: aRectangle origin;
				  initialExtent: aRectangle extent ].
	^ nil
]

{ #category : 'snapshot' }
TGolapSnapshotablePresenter >> openBounds: aRectangle [

	| window |
	window := self asWindow.
	aRectangle ifNotNil: [
			window
				initialPosition: aRectangle origin;
				initialExtent: aRectangle extent ].
	^ window
]

{ #category : 'snapshot' }
TGolapSnapshotablePresenter >> windowJSON [

	self window ifNotNil: [ :window |
			window isMinimized ifTrue: [ ^ 'minimized' ].
			window isMaximized ifTrue: [ ^ 'maximized' ].
			window isOpen ifTrue: [ ^ 'open' ] ].
	^ 'closed'
]
