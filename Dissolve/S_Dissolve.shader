Shader "Dissolve/Dissolve"
{
    Properties
    {
        _Color ("Color", Color) = (0, 0, 0, 0)
        _EdgeColor ("Edge Color", Color) = (1, 0, 0, 0)
        _EdgeIntensity ("Edge Intensity", Float) = 10
        _DissolveTex ("DIssolve Texture", 2D) = "gray" {}
        _DissolveAmount ("Dissolve Amount", Range(0, 1)) = 0
        _EdgeSharpness ("Edge Sharpness", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" "IgnoreProjector" = "True"}
        Cull Off

        CGPROGRAM
        #pragma surface surf Lambert alpha:fade
        #pragma target 3.0

        fixed4 _Color;
        fixed4 _EdgeColor;
        float _EdgeIntensity;
        sampler2D _DissolveTex;
        fixed _DissolveAmount;
        fixed _EdgeSharpness;

        struct Input
        {
            float2 uv_DissolveTex;
        };
        
        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
            // 映射
            float smoothStepMin = _DissolveAmount * (1 + _EdgeSharpness) - _EdgeSharpness;
            float smoothStepMax = smoothStepMin + _EdgeSharpness;
            
            // 贴图采样
            fixed dissolve = tex2D(_DissolveTex, IN.uv_DissolveTex).r;
            fixed alpha = saturate(smoothstep(smoothStepMin, smoothStepMax, dissolve));
            fixed edge = frac(alpha);
            // 着色
            o.Alpha = alpha;
            o.Emission = _Color + edge * _EdgeColor * _EdgeIntensity;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
