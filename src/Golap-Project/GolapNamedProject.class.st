Class {
	#name : 'GolapNamedProject',
	#superclass : 'GolapProject',
	#instVars : [
		'projectFile'
	],
	#category : 'Golap-Project',
	#package : 'Golap-Project'
}

{ #category : 'instance creation' }
GolapNamedProject class >> named: aString [

	^ self new
		  projectName: aString;
		  yourself
]

{ #category : 'instance creation' }
GolapNamedProject class >> on: aFileReference [

	^ self new
		  projectFile: aFileReference;
		  yourself
]

{ #category : 'operations' }
GolapNamedProject class >> open [

	self current open
]

{ #category : 'accessing' }
GolapNamedProject class >> projectBaseDirectory [

	^ self golapDirectory
]

{ #category : 'operations' }
GolapNamedProject class >> save [

	self current save
]

{ #category : 'converting' }
GolapNamedProject >> asJSON [

	^ super asJSON
		  at: 'project' put: self projectName;
		  yourself
]

{ #category : 'testing' }
GolapNamedProject >> exists [

	^ projectFile notNil and: [ projectFile exists ]
]

{ #category : 'converting' }
GolapNamedProject >> fromJSON: aDictionaryOrNil [

	aDictionaryOrNil at: 'project' ifPresent: [ :projectName | self projectName: projectName ].
	super fromJSON: aDictionaryOrNil
]

{ #category : 'controlling' }
GolapNamedProject >> ifDefault: aBlock otherwise: anotherBlock [

	^ anotherBlock cull: self
]

{ #category : 'accessing' }
GolapNamedProject >> projectFile [

	^ projectFile
]

{ #category : 'accessing' }
GolapNamedProject >> projectFile: aFileReference [

	projectFile := aFileReference.
	self updateWorldWindowTitle
]

{ #category : 'accessing' }
GolapNamedProject >> projectName [

	^ projectFile ifNotNil: [
		  projectFile basenameWithoutExtension: self class fileExtension ]
]

{ #category : 'accessing' }
GolapNamedProject >> projectName: aString [

	self projectFile:
		(self class projectBaseDirectory / aString withExtension:
			 self class fileExtension)
]

{ #category : 'updating' }
GolapNamedProject >> updateMenubar [

	GolapMenubar reset
]
