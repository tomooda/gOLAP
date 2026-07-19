Class {
	#name : 'BaselineOfGolap',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfGolap',
	#package : 'BaselineOfGolap'
}

{ #category : 'accessing' }
BaselineOfGolap class >> codename [

	^ '吉祥寺'
]

{ #category : 'accessing' }
BaselineOfGolap class >> logoImage [

	^ Form fromFileNamed: self logoImageFileReference
]

{ #category : 'accessing' }
BaselineOfGolap class >> logoImageFileReference [

	^ (FileLocator localDirectory / 'gOLAP') ensureCreateDirectory
	  / 'gOLAP-logo.png'
]

{ #category : 'accessing' }
BaselineOfGolap class >> logoImageWithCodename [

	<script>
	| logoImage font form codename |
	logoImage := self logoImage.
	font := (LogicalFont familyName: 'PlemolJP' pointSize: 24) realFont.
	form := Form
		        extent: logoImage extent + (0 @ (font height + 2))
		        depth: 32.
	codename := self codename.
	form getCanvas
		fillColor: Color white;
		translucentImage: logoImage at: 0 @ 0;
		drawString: codename
		at: form extent
			- ((font widthOfString: codename) + 10 @ (font height + 4))
		font: font
		color: Color lightGray.
	^ form
]

{ #category : 'baseline' }
BaselineOfGolap >> baseline: spec [

	<baseline>
	spec for: #common do: [
			spec baseline: 'RoassalExporters' with: [
					spec repository:
						'github://pharo-graphics/RoassalExporters:pharo13/src' ].
			spec
				baseline: 'Phleeter'
				with: [ spec repository: 'github://tomooda/Phleeter:main/src' ].
			spec
				baseline: 'Selphie'
				with: [ spec repository: 'github://tomooda/Selphie/src' ].
			spec
				baseline: 'HiDeHo'
				with: [ spec repository: 'github://tomooda/HiDeHo:main/src' ].
			spec
				baseline: 'DataFrame'
				with: [ spec repository: 'github://PolyMathOrg/DataFrame/src' ].
			spec
				baseline: 'PetitParser2Core'
				with: [ spec repository: 'github://kursjan/petitparser2/' ].
			spec
				baseline: 'Xenq'
				with: [ spec repository: 'github://tomooda/Xenq:main/src' ].
			spec
				package: 'Golap-Application'
				with: [ spec requires: #( 'Phleeter' ) ];
				package: 'Golap-Clustering' with: [ spec requires: #(  ) ];
				package: 'Golap-Models' with: [ spec requires: #( 'DataFrame' ) ];
				package: 'Golap-Networking' with: [ spec requires: #(  ) ];
				package: 'Golap-Project'
				with: [ spec requires: #( 'DataFrame' 'Golap-Models'
						   'Golap-UI' ) ];
				package: 'Golap-Query'
				with: [ spec requires: #( 'PetitParser2Core' ) ];
				package: 'Golap-UI' with: [
						spec requires:
								#( 'Selphie' 'RoassalExporters' 'HiDeHo' 'DataFrame'
								   'Xenq' ) ].
			spec package: 'Golap-Visualization' with: [ spec requires: #(  ) ].
			spec postLoadDoIt: #postLoad.
			spec
				group: 'Core'
				with: #( 'Golap-Application' 'Golap-Clustering' 'Golap-Models'
					   'Golap-Networking' 'Golap-Project' 'Golap-Query' 'Golap-UI'
					   'Golap-Visualization' );
				group: 'default' with: #( 'Core' ) ]
]

{ #category : 'utilities' }
BaselineOfGolap >> installDesktopLogo [

	<script: 'BaselineOfGolap new installDesktopLogo'>
	| backgroundImage |
	backgroundImage := self class logoImageFileReference.
	PharoLightTheme beCurrent.
	backgroundImage ensureDelete.
	(IceRepository repositoryNamed: 'gOLAP') location / 'resources'
	/ backgroundImage basename copyTo: backgroundImage.
	PolymorphSystemSettings desktopLogoFileName: ''.
	PolymorphSystemSettings desktopLogoFileName: backgroundImage fullName
]

{ #category : 'utilities' }
BaselineOfGolap >> installFonts [

	<script: 'BaselineOfGolap new installFonts'>
	(IceRepository repositoryNamed: 'gOLAP') location / 'resources'
	/ 'Fonts' copyAllTo:
		(FileLocator workingDirectory / 'Fonts') ensureCreateDirectory.
	Smalltalk at: #PlemolJPRegular ifPresent: [ :fontClass |
		EmbeddedFreeTypeFontInstaller registerFont: fontClass.
		FreeTypeFontProvider current buildFamilies.
		StandardFonts setAllStandardFontsTo:
			(LogicalFont familyName: 'PlemolJP' pointSize: 10) ]
]

{ #category : 'utilities' }
BaselineOfGolap >> postLoad [

	self
		installDesktopLogo;
		installFonts
]
