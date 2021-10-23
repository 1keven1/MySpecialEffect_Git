// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "InkRender/Ink_Floor"
{
	Properties
	{
		_NoiseTex("NoiseTex", 2D) = "gray" {}
		_MianColor("MianColor", 2D) = "white" {}
		_PaperColor("PaperColor", Color) = (0,0,0,0)
		_MC_NoiseStrength("MC_NoiseStrength", Range( 0.1 , 1)) = 0.1
		_Saturate("Saturate", Range( 0 , 1)) = 1
		_MC_Tint1("MC_Tint1", Color) = (1,1,1,1)
		_Saturate_Smoothness("Saturate_Smoothness", Range( 0 , 1)) = 0.1
		_MC_Tint2("MC_Tint2", Color) = (0.2641509,0.2641509,0.2641509,1)
		_Desaturation("Desaturation", Range( -1 , 1)) = 0
		_Shadow_Intensity("Shadow_Intensity", Range( 0 , 1)) = 0.013
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#pragma target 3.0
		#pragma surface surf StandardCustomLighting keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float4 _PaperColor;
		uniform sampler2D _MianColor;
		uniform float4 _MianColor_ST;
		uniform half4 _MC_Tint1;
		uniform half4 _MC_Tint2;
		uniform sampler2D _NoiseTex;
		uniform float4 _NoiseTex_ST;
		uniform float _MC_NoiseStrength;
		uniform float _Desaturation;
		uniform float _Saturate;
		uniform float _Saturate_Smoothness;
		uniform float _Shadow_Intensity;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float2 uv_MianColor = i.uv_texcoord * _MianColor_ST.xy + _MianColor_ST.zw;
			float2 uv_NoiseTex = i.uv_texcoord * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
			float4 NoiseTextureV44 = tex2D( _NoiseTex, uv_NoiseTex );
			float4 break8 = NoiseTextureV44;
			float4 lerpResult14 = lerp( _MC_Tint1 , _MC_Tint2 , ( break8.b * _MC_NoiseStrength ));
			float4 temp_output_15_0 = ( tex2D( _MianColor, uv_MianColor ) * lerpResult14 );
			float3 desaturateInitialColor35 = temp_output_15_0.rgb;
			float desaturateDot35 = dot( desaturateInitialColor35, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar35 = lerp( desaturateInitialColor35, desaturateDot35.xxx, _Desaturation );
			float temp_output_21_0 = ( _Saturate * ( _Saturate_Smoothness + 1.0 ) );
			float3 desaturateInitialColor32 = temp_output_15_0.rgb;
			float desaturateDot32 = dot( desaturateInitialColor32, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar32 = lerp( desaturateInitialColor32, desaturateDot32.xxx, 1.0 );
			float smoothstepResult29 = smoothstep( ( temp_output_21_0 - _Saturate_Smoothness ) , temp_output_21_0 , ( (desaturateVar32).x * break8.r ));
			float4 lerpResult25 = lerp( _PaperColor , float4( desaturateVar35 , 0.0 ) , ( 1.0 - smoothstepResult29 ));
			float4 MainColor16 = lerpResult25;
			c.rgb = ( MainColor16 * saturate( ( ase_lightAtten + _Shadow_Intensity ) ) ).rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			float2 uv_MianColor = i.uv_texcoord * _MianColor_ST.xy + _MianColor_ST.zw;
			float2 uv_NoiseTex = i.uv_texcoord * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
			float4 NoiseTextureV44 = tex2D( _NoiseTex, uv_NoiseTex );
			float4 break8 = NoiseTextureV44;
			float4 lerpResult14 = lerp( _MC_Tint1 , _MC_Tint2 , ( break8.b * _MC_NoiseStrength ));
			float4 temp_output_15_0 = ( tex2D( _MianColor, uv_MianColor ) * lerpResult14 );
			float3 desaturateInitialColor35 = temp_output_15_0.rgb;
			float desaturateDot35 = dot( desaturateInitialColor35, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar35 = lerp( desaturateInitialColor35, desaturateDot35.xxx, _Desaturation );
			float temp_output_21_0 = ( _Saturate * ( _Saturate_Smoothness + 1.0 ) );
			float3 desaturateInitialColor32 = temp_output_15_0.rgb;
			float desaturateDot32 = dot( desaturateInitialColor32, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar32 = lerp( desaturateInitialColor32, desaturateDot32.xxx, 1.0 );
			float smoothstepResult29 = smoothstep( ( temp_output_21_0 - _Saturate_Smoothness ) , temp_output_21_0 , ( (desaturateVar32).x * break8.r ));
			float4 lerpResult25 = lerp( _PaperColor , float4( desaturateVar35 , 0.0 ) , ( 1.0 - smoothstepResult29 ));
			float4 MainColor16 = lerpResult25;
			float4 temp_output_17_0 = MainColor16;
			o.Albedo = temp_output_17_0.rgb;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
104;616;1182;729.6667;-122.5123;238.1992;1.66546;True;False
Node;AmplifyShaderEditor.CommentaryNode;1;-1742.017,-727.8873;Inherit;False;1103.65;498.3911;采样噪点贴图;4;4;3;2;37;Nosie;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;2;-1696.017,-637.8873;Inherit;True;Property;_NoiseTex;NoiseTex;0;0;Create;True;0;0;0;False;0;False;83e7d892f31526a40bdd44154aabc53d;83e7d892f31526a40bdd44154aabc53d;False;gray;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TextureCoordinatesNode;37;-1445.784,-526.998;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-1197.646,-634.6436;Inherit;True;Property;_TextureSample0;Texture Sample 0;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;4;-844.1216,-591.1467;Inherit;False;NoiseTextureV4;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;5;-1737.566,-170.9451;Inherit;False;2766.395;905.0927;MainColor;25;22;21;20;19;18;31;29;27;32;16;25;15;14;13;12;11;10;9;7;8;6;30;35;36;34;MainColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;6;-1687.566,435.3915;Inherit;False;4;NoiseTextureV4;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;8;-1469.566,436.3915;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;7;-1628.323,593.5436;Inherit;False;Property;_MC_NoiseStrength;MC_NoiseStrength;3;0;Create;True;0;0;0;False;0;False;0.1;0.613;0.1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;10;-1685.975,-120.946;Inherit;True;Property;_MianColor;MianColor;1;0;Create;True;0;0;0;False;0;False;fd033dd8b0519e3439fb70b85d23a9ae;fd033dd8b0519e3439fb70b85d23a9ae;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.ColorNode;9;-1408.673,77.0533;Half;False;Property;_MC_Tint1;MC_Tint1;5;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;11;-1412.531,250.8334;Half;False;Property;_MC_Tint2;MC_Tint2;7;0;Create;True;0;0;0;False;0;False;0.2641509,0.2641509,0.2641509,1;0.5582097,0.5660378,0.3652546,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-1232.948,477.6447;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;14;-1005.088,296.8099;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;13;-1420.673,-112.9461;Inherit;True;Property;_TextureSample1;Texture Sample 1;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-806.436,-115.0042;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-123.603,498.3709;Inherit;False;Property;_Saturate_Smoothness;Saturate_Smoothness;6;0;Create;True;0;0;0;False;0;False;0.1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DesaturateOpNode;32;-581.2944,116.8124;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-104.8709,390.5414;Inherit;False;Property;_Saturate;Saturate;4;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;181.6877,424.945;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;27;-379.7265,117.2216;Inherit;True;True;False;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;376.4785,353.6745;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-83.96765,95.7182;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;22;548.0248,442.0926;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;29;111.9461,152.1744;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-752.4135,44.07141;Inherit;False;Property;_Desaturation;Desaturation;8;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;30;327.4953,-224.7536;Inherit;False;Property;_PaperColor;PaperColor;2;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;31;323.2679,123.0688;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DesaturateOpNode;35;-501.5793,-23.31035;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightAttenuation;43;1085.298,98.54272;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;1069.29,248.2655;Inherit;False;Property;_Shadow_Intensity;Shadow_Intensity;9;0;Create;True;0;0;0;False;0;False;0.013;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;25;591.1086,-11.76522;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;45;1334.29,168.2655;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;809.1319,-15.50631;Inherit;False;MainColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;1063.215,-142.5496;Inherit;False;16;MainColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;46;1448.29,173.2655;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;1619.631,11.78262;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;38;-161.8851,371.6077;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1798.93,-226.8299;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;InkRender/Ink_Floor;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;37;2;2;0
WireConnection;3;0;2;0
WireConnection;3;1;37;0
WireConnection;3;7;2;1
WireConnection;4;0;3;0
WireConnection;8;0;6;0
WireConnection;12;0;8;2
WireConnection;12;1;7;0
WireConnection;14;0;9;0
WireConnection;14;1;11;0
WireConnection;14;2;12;0
WireConnection;13;0;10;0
WireConnection;15;0;13;0
WireConnection;15;1;14;0
WireConnection;32;0;15;0
WireConnection;19;0;18;0
WireConnection;27;0;32;0
WireConnection;21;0;20;0
WireConnection;21;1;19;0
WireConnection;34;0;27;0
WireConnection;34;1;8;0
WireConnection;22;0;21;0
WireConnection;22;1;18;0
WireConnection;29;0;34;0
WireConnection;29;1;22;0
WireConnection;29;2;21;0
WireConnection;31;0;29;0
WireConnection;35;0;15;0
WireConnection;35;1;36;0
WireConnection;25;0;30;0
WireConnection;25;1;35;0
WireConnection;25;2;31;0
WireConnection;45;0;43;0
WireConnection;45;1;48;0
WireConnection;16;0;25;0
WireConnection;46;0;45;0
WireConnection;42;0;17;0
WireConnection;42;1;46;0
WireConnection;0;0;17;0
WireConnection;0;13;42;0
ASEEND*/
//CHKSM=3AC94F2F34ABB0538C8159F650692CB7651AD5D8