Extension { #name : 'Golap' }

{ #category : '*Golap-Notepad' }
Golap >> newClip [

	| image |
	image := (self activeVisualizationDo: #image) ifNil: [ self withAdapterDo: [ :a | a widgetDo: [ :w | w asForm ] ] ].
	^ GolapGraphClip new
		  image: image;
		  golap: self asJSON;
		  yourself
]
