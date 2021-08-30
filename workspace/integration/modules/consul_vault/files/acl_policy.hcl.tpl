node_prefix "" {
  policy = "read"
}
service_prefix "" {
  policy = "read"
}
node_prefix "${name}" {
  policy = "write"
}
agent_prefix "${name}" {
  policy = "write"
}
