Extension { #name : #FreeTypeFace }

{ #category : #'*Golap-UI' }
FreeTypeFace >> filename [

	| fileRef basename provider |
	filename ifNil: [ ^ filename ].
	fileRef := filename asFileReference.
	fileRef ifExists: [ ^ filename ].
	basename := fileRef basename.
	provider := FreeTypeFontProvider current.
	provider platformImageRelativeDirectories do: [ :each |
		each / basename ifExists: [ :ref | ^ filename := ref pathString ] ].
	provider platformVMRelativeDirectories do: [ :each |
		each / basename ifExists: [ :ref | ^ filename := ref pathString ] ].
	provider platformAbsoluteDirectories do: [ :each |
		each / basename ifExists: [ :ref | ^ filename := ref pathString ] ].
	^ filename
]
