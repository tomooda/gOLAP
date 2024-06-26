Extension { #name : 'FreeTypeFileInfo' }

{ #category : '*Golap-UI' }
FreeTypeFileInfo class >> startUp: resuming [
	<script: 'SessionManager default registerSystemClassNamed: self name'>

	resuming ifTrue: [
		self allInstancesDo: [ :fileInfo | fileInfo updateAbsolutePath ] ]
]

{ #category : '*Golap-UI' }
FreeTypeFileInfo >> updateAbsolutePath [

	| fileRef basename provider |
	absoluteOrRelativePath = true ifFalse: [ ^ self ].
	fileRef := absolutePath asFileReference.
	fileRef exists ifTrue: [ ^ self ].
	basename := fileRef basename.
	provider := FreeTypeFontProvider current.
	provider platformImageRelativeDirectories do: [ :each |
		each / basename ifExists: [ :ref | ^ absolutePath := ref pathString ] ].
	provider platformVMRelativeDirectories do: [ :each |
		each / basename ifExists: [ :ref | ^ absolutePath := ref pathString ] ].
	provider platformAbsoluteDirectories do: [ :each |
		each / basename ifExists: [ :ref | ^ absolutePath := ref pathString ] ]
]
