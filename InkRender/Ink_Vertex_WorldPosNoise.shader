// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Ink Render/Ink_Vertex_WorldPosNoise"
{
	Properties
	{
		_ASEOutlineColor( "Outline Color", Color ) = (0,0,0,0)
		_ASEOutlineWidth( "Outline Width", Float ) = 0
		_NoiseTex("NoiseTex", 2D) = "gray" {}
		_Noise_Tiling("Noise_Tiling", Float) = 1
		_MianColor("MianColor", 2D) = "white" {}
		_MC_NoiseStrength("MC_NoiseStrength", Range( 0.1 , 1)) = 0.1
		_MC_Tint1("MC_Tint1", Color) = (1,1,1,1)
		_MC_Tint2("MC_Tint2", Color) = (0.2641509,0.2641509,0.2641509,1)
		_Lighting_ShadowPos("Lighting_ShadowPos", Range( 0 , 1)) = 0.5
		_Lighting_ShadowSmoothness("Lighting_ShadowSmoothness", Range( 0 , 0.5)) = 0.05
		_Lighting_ShadowNoiseStrength("Lighting_ShadowNoiseStrength", Range( 0 , 0.5)) = 0.1
		_LIghting_ShadowColor("LIghting_ShadowColor", Color) = (0.2641509,0.2641509,0.2641509,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ }
		Cull Front
		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc 
		
		float4 _ASEOutlineColor;
		float _ASEOutlineWidth;
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			v.vertex.xyz += ( v.normal * _ASEOutlineWidth );
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			o.Emission = _ASEOutlineColor.rgb;
			o.Alpha = 1;
		}
		ENDCG
		

		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
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

		uniform sampler2D _MianColor;
		uniform float4 _MianColor_ST;
		uniform half4 _MC_Tint1;
		uniform half4 _MC_Tint2;
		uniform sampler2D _NoiseTex;
		uniform float _Noise_Tiling;
		uniform float _MC_NoiseStrength;
		uniform float4 _LIghting_ShadowColor;
		uniform float _Lighting_ShadowPos;
		uniform float _Lighting_ShadowSmoothness;
		uniform float _Lighting_ShadowNoiseStrength;

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
			float4 color130 = IsGammaSpace() ? float4(1,1,1,0) : float4(1,1,1,0);
			float3 ase_worldPos = i.worldPos;
			float3 objToWorld3_g11 = mul( unity_ObjectToWorld, float4( float3(0,0,0), 1 ) ).xyz;
			float3 temp_output_5_0_g11 = ( ase_worldPos - objToWorld3_g11 );
			float temp_output_19_0_g11 = _Noise_Tiling;
			float3 ase_worldNormal = i.worldNormal;
			float3 temp_output_21_0_g11 = abs( ase_worldNormal );
			float temp_output_28_0_g11 = 2.5;
			float temp_output_29_0_g11 = 1.5;
			float4 lerpResult31_g11 = lerp( tex2D( _NoiseTex, ( (temp_output_5_0_g11).xy * temp_output_19_0_g11 * 1.0 ) ) , tex2D( _NoiseTex, ( (temp_output_5_0_g11).xz * temp_output_19_0_g11 * 1.0 ) ) , saturate( ( pow( (temp_output_21_0_g11).y , temp_output_28_0_g11 ) * temp_output_29_0_g11 ) ));
			float4 lerpResult30_g11 = lerp( lerpResult31_g11 , tex2D( _NoiseTex, ( (temp_output_5_0_g11).yz * temp_output_19_0_g11 * 1.0 ) ) , saturate( ( pow( (temp_output_21_0_g11).x , temp_output_28_0_g11 ) * temp_output_29_0_g11 ) ));
			float4 NoiseTextureV446 = lerpResult30_g11;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult101 = dot( ase_worldNormal , ase_worldlightDir );
			float smoothstepResult102 = smoothstep( _Lighting_ShadowPos , ( _Lighting_ShadowPos + _Lighting_ShadowSmoothness ) , ( ( ( ( NoiseTextureV446.b + -0.5 ) * 2.0 ) * _Lighting_ShadowNoiseStrength ) + dotResult101 ));
			float4 lerpResult128 = lerp( _LIghting_ShadowColor , color130 , smoothstepResult102);
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float2 uv_MianColor = i.uv_texcoord * _MianColor_ST.xy + _MianColor_ST.zw;
			float4 lerpResult60 = lerp( _MC_Tint1 , _MC_Tint2 , ( NoiseTextureV446.b * _MC_NoiseStrength ));
			float4 MainColor69 = ( tex2D( _MianColor, uv_MianColor ) * lerpResult60 );
			float lerpResult134 = lerp( 1.0 , ase_lightAtten , _WorldSpaceLightPos0.w);
			float4 Lighting107 = ( lerpResult128 * ase_lightColor * MainColor69 * lerpResult134 );
			c.rgb = Lighting107.rgb;
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
			float3 ase_worldPos = i.worldPos;
			float3 objToWorld3_g11 = mul( unity_ObjectToWorld, float4( float3(0,0,0), 1 ) ).xyz;
			float3 temp_output_5_0_g11 = ( ase_worldPos - objToWorld3_g11 );
			float temp_output_19_0_g11 = _Noise_Tiling;
			float3 ase_worldNormal = i.worldNormal;
			float3 temp_output_21_0_g11 = abs( ase_worldNormal );
			float temp_output_28_0_g11 = 2.5;
			float temp_output_29_0_g11 = 1.5;
			float4 lerpResult31_g11 = lerp( tex2D( _NoiseTex, ( (temp_output_5_0_g11).xy * temp_output_19_0_g11 * 1.0 ) ) , tex2D( _NoiseTex, ( (temp_output_5_0_g11).xz * temp_output_19_0_g11 * 1.0 ) ) , saturate( ( pow( (temp_output_21_0_g11).y , temp_output_28_0_g11 ) * temp_output_29_0_g11 ) ));
			float4 lerpResult30_g11 = lerp( lerpResult31_g11 , tex2D( _NoiseTex, ( (temp_output_5_0_g11).yz * temp_output_19_0_g11 * 1.0 ) ) , saturate( ( pow( (temp_output_21_0_g11).x , temp_output_28_0_g11 ) * temp_output_29_0_g11 ) ));
			float4 NoiseTextureV446 = lerpResult30_g11;
			float4 lerpResult60 = lerp( _MC_Tint1 , _MC_Tint2 , ( NoiseTextureV446.b * _MC_NoiseStrength ));
			float4 MainColor69 = ( tex2D( _MianColor, uv_MianColor ) * lerpResult60 );
			o.Albedo = MainColor69.rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
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
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
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
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
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
612.8;882.4;2048;1005.4;3646.233;1816.483;1.184596;True;False
Node;AmplifyShaderEditor.CommentaryNode;51;-2935.617,-1716.612;Inherit;False;1103.65;498.3911;采样噪点贴图;5;46;21;196;19;197;Nosie;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;197;-2870.789,-1384.217;Inherit;False;Property;_Noise_Tiling;Noise_Tiling;1;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;19;-2889.617,-1626.612;Inherit;True;Property;_NoiseTex;NoiseTex;0;0;Create;True;0;0;0;False;0;False;83e7d892f31526a40bdd44154aabc53d;83e7d892f31526a40bdd44154aabc53d;False;gray;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.FunctionNode;196;-2606.347,-1592.595;Inherit;False;WorldCoordinate3Tex;2;;11;3c51aa2c77ac90e47bcd53785d22b6bc;0;4;18;SAMPLER2D;;False;19;FLOAT;1;False;28;FLOAT;2.5;False;29;FLOAT;1.5;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;161;-2917.008,250.037;Inherit;False;1882.071;809.4917;Comment;23;107;134;93;90;113;115;92;128;130;129;102;112;105;106;122;126;127;101;97;91;125;124;123;Lighting;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;46;-2274.167,-1585.724;Inherit;False;NoiseTextureV4;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;71;-2931.166,-1159.67;Inherit;False;1430.698;879.891;MainColor;11;69;52;53;56;62;44;61;42;45;60;43;MainColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;-2881.166,-553.3332;Inherit;False;46;NoiseTextureV4;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;123;-2867.008,300.037;Inherit;False;46;NoiseTextureV4;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-2821.923,-395.1811;Inherit;False;Property;_MC_NoiseStrength;MC_NoiseStrength;14;0;Create;True;0;0;0;False;0;False;0.1;0.1;0.1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;124;-2642.008,303.037;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;53;-2663.166,-552.3332;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-2426.548,-511.08;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;42;-2879.575,-1109.671;Inherit;True;Property;_MianColor;MianColor;13;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.ColorNode;61;-2606.131,-737.8916;Half;False;Property;_MC_Tint2;MC_Tint2;16;0;Create;True;0;0;0;False;0;False;0.2641509,0.2641509,0.2641509,1;0.2641509,0.2641509,0.2641509,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;44;-2602.273,-911.6716;Half;False;Property;_MC_Tint1;MC_Tint1;15;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;91;-2847.392,689.8582;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;125;-2506.008,304.037;Inherit;False;ConstantBiasScale;-1;;14;63208df05c83e8e49a48ffbdce2e43a0;0;3;3;FLOAT;0;False;1;FLOAT;-0.5;False;2;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;97;-2838.413,519.2023;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;127;-2639.454,459.2952;Inherit;False;Property;_Lighting_ShadowNoiseStrength;Lighting_ShadowNoiseStrength;19;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;101;-2464.899,583.0618;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;105;-2479.965,767.3126;Inherit;False;Property;_Lighting_ShadowPos;Lighting_ShadowPos;17;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;45;-2614.273,-1101.671;Inherit;True;Property;_TextureSample1;Texture Sample 1;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;126;-2275.184,322.0431;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-2478.965,863.3126;Inherit;False;Property;_Lighting_ShadowSmoothness;Lighting_ShadowSmoothness;18;0;Create;True;0;0;0;False;0;False;0.05;0.05;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;60;-2198.688,-691.9149;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;112;-2145.075,773.8936;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-1888.307,-744.1317;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;122;-2097.586,534.0741;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;129;-1955.831,297.7637;Inherit;False;Property;_LIghting_ShadowColor;LIghting_ShadowColor;20;0;Create;True;0;0;0;False;0;False;0.2641509,0.2641509,0.2641509,0;0.2641509,0.2641509,0.2641509,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;102;-1914.873,723.0146;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;93;-1900.451,848.0026;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;69;-1725.269,-748.5383;Inherit;False;MainColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;90;-1894.279,937.2087;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.ColorNode;130;-1930.831,471.764;Inherit;False;Constant;_Color0;Color 0;15;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;128;-1661.876,492.0658;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;134;-1647.218,870.8356;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;115;-1720.609,770.3922;Inherit;False;69;MainColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;92;-1664.353,628.5809;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;-1401.734,597.8931;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;162;-2924.809,1100.597;Inherit;False;975.9496;393.1981;Comment;6;150;160;158;157;154;159;Reflection;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;107;-1239.392,590.5483;Inherit;False;Lighting;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;74;-2921.207,-201.8905;Inherit;False;1054.347;413.0486;Fresnel;6;3;41;39;72;2;68;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;191;-908.7021,577.1771;Inherit;False;1642.848;506.0271;Comment;13;178;180;187;188;186;163;5;167;164;184;190;173;174;Change Line Width By Distance;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;73;-924.5989,67.55981;Inherit;False;72;Fresnel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-690.623,-503.9913;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;32;-988.7542,-192.3621;Inherit;False;ConstantBiasScale;-1;;13;63208df05c83e8e49a48ffbdce2e43a0;0;3;3;FLOAT;0;False;1;FLOAT;-0.5;False;2;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;198;856.597,-357.4454;Inherit;False;69;MainColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;99;-350.2657,-263.616;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-723.7303,-198.1001;Inherit;False;Property;_Whiteline_Smoothness;Whiteline_Smoothness;11;0;Create;True;0;0;0;False;0;False;0.05;0.05;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;185;-738.3351,-277.7047;Inherit;False;163;OutlineWidthByDistance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;81;-235.1826,-386.604;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;193;-41.85608,-323.0032;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;171;-939.4616,221.1114;Inherit;False;163;OutlineWidthByDistance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-641.2509,-80.01045;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;77;-969.623,-467.9913;Inherit;False;ConstantBiasScale;-1;;12;63208df05c83e8e49a48ffbdce2e43a0;0;3;3;FLOAT;0;False;1;FLOAT;-0.5;False;2;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-1012.711,-62.23605;Inherit;False;Property;_Outline_NoiseStrength;Outline_NoiseStrength;7;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;85;-0.7813683,-100.2406;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-450.4485,14.16781;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;195;-111.8561,-565.0032;Inherit;False;Property;_Outline_Color;Outline_Color;4;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;80;-490.8145,-507.0096;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;194;144.1439,-413.0032;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;4;-253.8821,37.66228;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-969.9297,-571.2181;Inherit;False;Property;_Whiteline_NoiseStrength;Whiteline_NoiseStrength;10;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;134.2158,-656.3527;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;163;452.8123,627.1771;Inherit;False;OutlineWidthByDistance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;88;-252.848,170.1046;Inherit;False;Property;_Whiteline_Color;Whiteline_Color;8;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;50;-1136.915,-373.4789;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;47;-1374.64,-377.2945;Inherit;False;46;NoiseTextureV4;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;16;-536.4221,243.4107;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-941.4223,312.4106;Inherit;False;Property;_Outline_Smoothness;Outline_Smoothness;6;0;Create;True;0;0;0;False;0;False;0.05;0.05;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;-295.5231,-710.0502;Inherit;False;69;MainColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;82;-750.86,-354.0828;Inherit;False;Property;_Whiteline_Width;Whiteline_Width;9;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;174;293.5554,636.5946;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;192;304.1439,-488.0032;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;-702.8428,-658.169;Inherit;False;72;Fresnel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;72;-2091.661,-22.24619;Inherit;False;Fresnel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;167;-794.4855,743.8945;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;178;-837.723,960.1563;Inherit;False;72;Fresnel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;164;-588.1884,743.8461;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;-359.735,773.6317;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;187;-463.1243,968.2042;Inherit;False;Property;_ByDistance;ByDistance;12;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;188;-180.4124,970.0651;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;190;-194.3468,807.6357;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;175.2186,-74.2406;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;180;-659.0693,964.7703;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;186;-35.12433,790.2042;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;83;-476.57,-347.6225;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;87;368.6887,-255.8301;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-858.7021,629.3437;Inherit;False;Property;_Outline_Width;Outline_Width;5;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;2;-2884.207,-141.8905;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformDirectionNode;68;-2674.615,-136.1263;Inherit;False;Object;World;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;117;538.2745,-254.7437;Inherit;False;FinalDiffuse;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;1107.295,-169.4973;Inherit;False;107;Lighting;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;158;-2864.809,1149.597;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalVertexDataNode;150;-2856.162,1313.195;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;118;846.391,-476.9926;Inherit;False;117;FinalDiffuse;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;21;-2640.691,-1882.221;Inherit;True;Property;_TextureSample0;Texture Sample 0;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;154;-2328.475,1253.564;Inherit;False;float4 env = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, In0)@$return env@;4;False;1;True;In0;FLOAT3;0,0,0;In;;Inherit;False;SampleReflection;True;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ReflectOpNode;157;-2522.209,1260.14;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;159;-2669.809,1167.64;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;-1,-1,-1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;160;-2173.659,1247.205;Inherit;False;Reflection;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DotProductOpNode;41;-2377.745,-18.1169;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;39;-2239.008,-14.0199;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;3;-2722.412,25.55812;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;173;132.5317,636.9633;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1346.201,-418.6203;Float;False;True;-1;6;ASEMaterialInspector;0;0;CustomLighting;Ink Render/Ink_Vertex_WorldPosNoise;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;True;0;0,0,0,0;VertexOffset;False;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;196;18;19;0
WireConnection;196;19;197;0
WireConnection;46;0;196;0
WireConnection;124;0;123;0
WireConnection;53;0;52;0
WireConnection;62;0;53;2
WireConnection;62;1;56;0
WireConnection;125;3;124;2
WireConnection;101;0;97;0
WireConnection;101;1;91;0
WireConnection;45;0;42;0
WireConnection;126;0;125;0
WireConnection;126;1;127;0
WireConnection;60;0;44;0
WireConnection;60;1;61;0
WireConnection;60;2;62;0
WireConnection;112;0;105;0
WireConnection;112;1;106;0
WireConnection;43;0;45;0
WireConnection;43;1;60;0
WireConnection;122;0;126;0
WireConnection;122;1;101;0
WireConnection;102;0;122;0
WireConnection;102;1;105;0
WireConnection;102;2;112;0
WireConnection;69;0;43;0
WireConnection;128;0;129;0
WireConnection;128;1;130;0
WireConnection;128;2;102;0
WireConnection;134;1;93;0
WireConnection;134;2;90;2
WireConnection;113;0;128;0
WireConnection;113;1;92;0
WireConnection;113;2;115;0
WireConnection;113;3;134;0
WireConnection;107;0;113;0
WireConnection;79;0;89;0
WireConnection;79;1;77;0
WireConnection;32;3;50;0
WireConnection;99;0;83;0
WireConnection;99;1;100;0
WireConnection;81;0;80;0
WireConnection;81;1;83;0
WireConnection;81;2;99;0
WireConnection;193;0;81;0
WireConnection;33;0;32;0
WireConnection;33;1;35;0
WireConnection;77;3;50;1
WireConnection;85;0;81;0
WireConnection;36;0;33;0
WireConnection;36;1;73;0
WireConnection;80;0;75;0
WireConnection;80;1;79;0
WireConnection;194;0;195;0
WireConnection;194;1;193;0
WireConnection;4;0;36;0
WireConnection;4;1;171;0
WireConnection;4;2;16;0
WireConnection;57;0;70;0
WireConnection;57;1;81;0
WireConnection;163;0;174;0
WireConnection;50;0;47;0
WireConnection;16;0;171;0
WireConnection;16;1;17;0
WireConnection;174;0;173;0
WireConnection;192;0;57;0
WireConnection;192;1;194;0
WireConnection;72;0;39;0
WireConnection;164;0;167;0
WireConnection;184;0;164;0
WireConnection;184;1;180;0
WireConnection;188;0;187;0
WireConnection;190;0;184;0
WireConnection;86;0;85;0
WireConnection;86;1;4;0
WireConnection;86;2;88;0
WireConnection;180;0;178;0
WireConnection;186;1;190;0
WireConnection;186;2;188;0
WireConnection;83;0;82;0
WireConnection;83;1;185;0
WireConnection;87;0;192;0
WireConnection;87;1;86;0
WireConnection;68;0;2;0
WireConnection;117;0;87;0
WireConnection;21;0;19;0
WireConnection;21;7;19;1
WireConnection;154;0;157;0
WireConnection;157;0;159;0
WireConnection;157;1;150;0
WireConnection;159;0;158;0
WireConnection;160;0;154;0
WireConnection;41;0;68;0
WireConnection;41;1;3;0
WireConnection;39;0;41;0
WireConnection;173;0;5;0
WireConnection;173;1;186;0
WireConnection;0;0;198;0
WireConnection;0;13;108;0
ASEEND*/
//CHKSM=30926AAB1CBC85CAC4B5C719A97BB8D430DDA48A