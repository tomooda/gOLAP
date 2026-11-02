Extension { #name : 'Golap' }

{ #category : '*Golap-Notepad' }
Golap >> newClip [

	| image clip |
	image := (self activeVisualizationDo: #image) ifNil: [ self withAdapterDo: [ :a | a widgetDo: [ :w | w asForm ] ] ].
	clip := GolapGraphClip new
		        image: image;
		        golap: self asJSON;
		        yourself.
	^ clip asPresenter openModal isOk
		  ifTrue: [ clip ]
		  ifFalse: [ nil ]
]
