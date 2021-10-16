// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "InkDrop"
{
	Properties
	{
		_Opacity("Opacity", Range( 0 , 1)) = 1
		_SpecColor("Specular Color",Color)=(1,1,1,1)
		[Header(Refraction)]
		_ChromaticAberration("Chromatic Aberration", Range( 0 , 0.3)) = 0.1
		[HDR]_Color("Color", Color) = (0,0,0,0)
		_Opacity_Min("Opacity_Min", Range( 0 , 1)) = 0
		_Opacity_Max("Opacity_Max", Range( 0 , 1)) = 0.5
		_Opacity_P("Opacity_P", Float) = 1
		_Emissive_Noise("Emissive_Noise", 2D) = "white" {}
		_Emissive_TilingAndSpeed("Emissive_TilingAndSpeed", Vector) = (1,1,0.1,0.1)
		_Emissive_Min("Emissive_Min", Range( 0 , 1)) = 0.1
		_Emissive_Max("Emissive_Max", Range( 0 , 1)) = 0.7
		_WPO_Noise("WPO_Noise", 2D) = "gray" {}
		_WPO_TilingAndSpeed("WPO_TilingAndSpeed", Vector) = (1,1,0.1,0.1)
		_WPO_Strength("WPO_Strength", Float) = 1
		_IOR("IOR", Float) = 0.7
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		GrabPass{ }
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile _ALPHAPREMULTIPLY_ON
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
			float4 screenPos;
		};

		uniform sampler2D _WPO_Noise;
		uniform float4 _WPO_TilingAndSpeed;
		uniform float _WPO_Strength;
		uniform sampler2D _Emissive_Noise;
		uniform float4 _Emissive_TilingAndSpeed;
		uniform float _Emissive_Min;
		uniform float _Emissive_Max;
		uniform float _Opacity_P;
		uniform float4 _Color;
		uniform float _Opacity;
		uniform float _Opacity_Min;
		uniform float _Opacity_Max;
		uniform sampler2D _GrabTexture;
		uniform float _ChromaticAberration;
		uniform float _IOR;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float2 appendResult32 = (float2(_WPO_TilingAndSpeed.z , _WPO_TilingAndSpeed.w));
			float2 appendResult37 = (float2(_WPO_TilingAndSpeed.x , _WPO_TilingAndSpeed.y));
			float2 uv_TexCoord6 = v.texcoord.xy * appendResult37;
			float2 panner7 = ( 1.0 * _Time.y * appendResult32 + uv_TexCoord6);
			float3 ase_vertexNormal = v.normal.xyz;
			float temp_output_40_0 = ( 1.0 - pow( v.texcoord.xy.y , 2.0 ) );
			v.vertex.xyz += ( ( ( tex2Dlod( _WPO_Noise, float4( panner7, 0, 0.0) ).r + -0.5 ) * 2.0 ) * ase_vertexNormal * _WPO_Strength * 0.1 * temp_output_40_0 );
			v.vertex.w = 1;
		}

		inline float4 Refraction( Input i, SurfaceOutput o, float indexOfRefraction, float chomaticAberration ) {
			float3 worldNormal = o.Normal;
			float4 screenPos = i.screenPos;
			#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
			#else
				float scale = 1.0;
			#endif
			float halfPosW = screenPos.w * 0.5;
			screenPos.y = ( screenPos.y - halfPosW ) * _ProjectionParams.x * scale + halfPosW;
			#if SHADER_API_D3D9 || SHADER_API_D3D11
				screenPos.w += 0.00000000001;
			#endif
			float2 projScreenPos = ( screenPos / screenPos.w ).xy;
			float3 worldViewDir = normalize( UnityWorldSpaceViewDir( i.worldPos ) );
			float3 refractionOffset = ( indexOfRefraction - 1.0 ) * mul( UNITY_MATRIX_V, float4( worldNormal, 0.0 ) ) * ( 1.0 - dot( worldNormal, worldViewDir ) );
			float2 cameraRefraction = float2( refractionOffset.x, refractionOffset.y );
			float4 redAlpha = tex2D( _GrabTexture, ( projScreenPos + cameraRefraction ) );
			float green = tex2D( _GrabTexture, ( projScreenPos + ( cameraRefraction * ( 1.0 - chomaticAberration ) ) ) ).g;
			float blue = tex2D( _GrabTexture, ( projScreenPos + ( cameraRefraction * ( 1.0 + chomaticAberration ) ) ) ).b;
			return float4( redAlpha.r, green, blue, redAlpha.a );
		}

		void RefractionF( Input i, SurfaceOutput o, inout half4 color )
		{
			#ifdef UNITY_PASS_FORWARDBASE
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float3 normalizeResult75 = normalize( ase_vertexNormal );
			float3 objToWorldDir82 = mul( unity_ObjectToWorld, float4( normalizeResult75, 0 ) ).xyz;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult14 = dot( objToWorldDir82 , ase_worldViewDir );
			float temp_output_22_0 = pow( saturate( dotResult14 ) , _Opacity_P );
			float smoothstepResult16 = smoothstep( _Opacity_Min , _Opacity_Max , temp_output_22_0);
			float temp_output_73_0 = saturate( _Opacity );
			float temp_output_69_0 = ( smoothstepResult16 * temp_output_73_0 );
			float lerpResult63 = lerp( 1.0 , _IOR , temp_output_69_0);
			color.rgb = color.rgb + Refraction( i, o, lerpResult63, _ChromaticAberration ) * ( 1 - color.a );
			color.a = 1;
			#endif
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float2 appendResult52 = (float2(_Emissive_TilingAndSpeed.z , _Emissive_TilingAndSpeed.w));
			float2 appendResult50 = (float2(_Emissive_TilingAndSpeed.x , _Emissive_TilingAndSpeed.y));
			float2 uv_TexCoord51 = i.uv_texcoord * appendResult50;
			float2 panner53 = ( 1.0 * _Time.y * appendResult52 + uv_TexCoord51);
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float3 normalizeResult75 = normalize( ase_vertexNormal );
			float3 objToWorldDir82 = mul( unity_ObjectToWorld, float4( normalizeResult75, 0 ) ).xyz;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult14 = dot( objToWorldDir82 , ase_worldViewDir );
			float temp_output_22_0 = pow( saturate( dotResult14 ) , _Opacity_P );
			float smoothstepResult45 = smoothstep( _Emissive_Min , _Emissive_Max , temp_output_22_0);
			float temp_output_40_0 = ( 1.0 - pow( i.uv_texcoord.y , 2.0 ) );
			float temp_output_73_0 = saturate( _Opacity );
			o.Emission = ( ( pow( tex2D( _Emissive_Noise, panner53 ).r , 4.0 ) * smoothstepResult45 * _Color * temp_output_40_0 ) * temp_output_73_0 ).rgb;
			o.Specular = 0.0;
			o.Gloss = 0.0;
			float smoothstepResult16 = smoothstep( _Opacity_Min , _Opacity_Max , temp_output_22_0);
			float temp_output_69_0 = ( smoothstepResult16 * temp_output_73_0 );
			o.Alpha = temp_output_69_0;
			o.Normal = o.Normal + 0.00001 * i.screenPos * i.worldPos;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf BlinnPhong alpha:fade keepalpha finalcolor:RefractionF fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 screenPos : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.screenPos = IN.screenPos;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
66.4;533.6;1700.8;895.8;2880.165;-3.82616;1;True;False
Node;AmplifyShaderEditor.NormalVertexDataNode;11;-2361.159,132.8596;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;49;-1558.428,-200.8541;Inherit;False;Property;_Emissive_TilingAndSpeed;Emissive_TilingAndSpeed;9;0;Create;True;0;0;0;False;0;False;1,1,0.1,0.1;1,1,0.1,0.1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;75;-2140.353,170.0415;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;12;-2369.159,300.8596;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformDirectionNode;82;-1897.165,159.8262;Inherit;False;Object;World;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector4Node;36;-1615.12,1084.379;Inherit;False;Property;_WPO_TilingAndSpeed;WPO_TilingAndSpeed;13;0;Create;True;0;0;0;False;0;False;1,1,0.1,0.1;1,1,0.1,0.1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;50;-1247.428,-258.8542;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;37;-1274.12,960.3789;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;14;-1628.159,248.8595;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;52;-1239.701,-143.2692;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;51;-1090.673,-375.3859;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;24;-1451.509,391.9063;Inherit;False;Property;_Opacity_P;Opacity_P;7;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;28;-2303.271,597.1202;Inherit;True;Property;_WPO_Noise;WPO_Noise;12;0;Create;True;0;0;0;False;0;False;None;None;False;gray;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;42;-531.7021,1436.648;Inherit;False;Constant;_Float1;Float 1;9;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;61;-1930.304,-496.1005;Inherit;True;Property;_Emissive_Noise;Emissive_Noise;8;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.DynamicAppendNode;32;-1207.393,1081.964;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-1117.365,843.8472;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;38;-548.1791,1306.769;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;15;-1487.159,246.8595;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;53;-810.6725,-371.3859;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-1116.732,106.8046;Inherit;False;Property;_Emissive_Max;Emissive_Max;11;0;Create;True;0;0;0;False;0;False;0.7;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-484.0691,-182.8164;Inherit;False;Constant;_Float2;Float 2;10;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-806.6042,617.1113;Inherit;False;Property;_Opacity;Opacity;0;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1099.159,476.8596;Inherit;False;Property;_Opacity_Min;Opacity_Min;5;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;7;-837.3645,847.8472;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;22;-1294.509,253.9062;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;47;-1716.998,732.3824;Inherit;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-1118.732,28.80453;Inherit;False;Property;_Emissive_Min;Emissive_Min;10;0;Create;True;0;0;0;False;0;False;0.1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;46;-576.4203,-418.8399;Inherit;True;Property;_TextureSample0;Texture Sample 0;11;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;41;-328.902,1368.448;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1103.159,553.8596;Inherit;False;Property;_Opacity_Max;Opacity_Max;6;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;45;-744.7323,18.80453;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;16;-725.1592,466.8596;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-585.3645,704.8472;Inherit;True;Property;_Texture1;Texture1;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;21;-356.7377,94.0321;Inherit;False;Property;_Color;Color;4;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;55;-244.0691,-239.8164;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;73;-488.6038,622.1113;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;40;-188.8744,1356.564;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-530.3646,1098.847;Inherit;False;Property;_WPO_Strength;WPO_Strength;14;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;15.07397,-40.74316;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-327.5913,430.7046;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;33;-255.7566,743.3629;Inherit;False;ConstantBiasScale;-1;;3;63208df05c83e8e49a48ffbdce2e43a0;0;3;3;FLOAT;0;False;1;FLOAT;-0.5;False;2;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-521.7566,1187.363;Inherit;False;Constant;_Float0;Float 0;7;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;65;16.62451,344.0718;Inherit;False;Property;_IOR;IOR;15;0;Create;True;0;0;0;False;0;False;0.7;0.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;27.52451,265.3719;Inherit;False;Constant;_Float3;Float 3;11;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;8;-533.3646,953.8472;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-43.36457,932.8472;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;68;369.4263,373.3712;Inherit;False;Constant;_Float5;Float 5;13;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;67;367.4263,288.3712;Inherit;False;Constant;_Float4;Float 4;13;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;63;187.0585,349.2621;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;212.2622,-9.217529;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;813.343,253.817;Float;False;True;-1;2;ASEMaterialInspector;0;0;BlinnPhong;InkDrop;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;2;-1;0;False;0;0;False;-1;1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;75;0;11;0
WireConnection;82;0;75;0
WireConnection;50;0;49;1
WireConnection;50;1;49;2
WireConnection;37;0;36;1
WireConnection;37;1;36;2
WireConnection;14;0;82;0
WireConnection;14;1;12;0
WireConnection;52;0;49;3
WireConnection;52;1;49;4
WireConnection;51;0;50;0
WireConnection;32;0;36;3
WireConnection;32;1;36;4
WireConnection;6;0;37;0
WireConnection;15;0;14;0
WireConnection;53;0;51;0
WireConnection;53;2;52;0
WireConnection;7;0;6;0
WireConnection;7;2;32;0
WireConnection;22;0;15;0
WireConnection;22;1;24;0
WireConnection;47;0;28;0
WireConnection;46;0;61;0
WireConnection;46;1;53;0
WireConnection;41;0;38;2
WireConnection;41;1;42;0
WireConnection;45;0;22;0
WireConnection;45;1;44;0
WireConnection;45;2;43;0
WireConnection;16;0;22;0
WireConnection;16;1;17;0
WireConnection;16;2;18;0
WireConnection;3;0;47;0
WireConnection;3;1;7;0
WireConnection;55;0;46;1
WireConnection;55;1;56;0
WireConnection;73;0;72;0
WireConnection;40;0;41;0
WireConnection;54;0;55;0
WireConnection;54;1;45;0
WireConnection;54;2;21;0
WireConnection;54;3;40;0
WireConnection;69;0;16;0
WireConnection;69;1;73;0
WireConnection;33;3;3;1
WireConnection;9;0;33;0
WireConnection;9;1;8;0
WireConnection;9;2;10;0
WireConnection;9;3;34;0
WireConnection;9;4;40;0
WireConnection;63;0;64;0
WireConnection;63;1;65;0
WireConnection;63;2;69;0
WireConnection;74;0;54;0
WireConnection;74;1;73;0
WireConnection;0;2;74;0
WireConnection;0;3;67;0
WireConnection;0;4;68;0
WireConnection;0;8;63;0
WireConnection;0;9;69;0
WireConnection;0;11;9;0
ASEEND*/
//CHKSM=8250773FF58FD9DEBAF3807CD93E2AC06F82D6D9