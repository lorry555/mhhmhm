<script>
    let { href = "", title = "", children } = $props();
</script>

<a target="_blank" rel="noreferrer" {href} {title}>{@render children?.()}</a>

<style>
    a {
        color: #007bff;
        text-decoration: none;
    }
</style>
