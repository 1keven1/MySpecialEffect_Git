Shader "Ink Render/Outline_Fresnel_Surf"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 0)
        _OutlineWidth ("Outline Width", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Lambert
        #pragma target 5.0

        struct Input
        {
            float2 uv_MainTex;
            float3 viewDir;
            float3 worldNormal;
        };
        
        fixed4 _Color;
        fixed4 _OutlineColor;
        fixed _OutlineWidth;

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c =_Color;
            // Outline
            fixed fresnel = saturate(dot(IN.viewDir, IN.worldNormal));
            o.Albedo = lerp(_OutlineColor, c.rgb, saturate(sign(fresnel - _OutlineWidth)));
        }
        ENDCG
    }
    FallBack "Diffuse"
}
